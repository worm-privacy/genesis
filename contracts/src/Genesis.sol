// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract Genesis is ReentrancyGuard {
    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;
    using SafeERC20 for IERC20;

    address public master;
    IERC20 public token;

    struct SharpEmission {
        uint256 startTime;
        uint256 amount;
    }

    struct Share {
        uint256 id;
        address owner;

        SharpEmission[] sharpEmissions;

        uint256 linearEmissionStartTime;
        uint256 linearEmissionCoinPerSecond;
        uint256 linearEmissionCap;

        uint256 total;
    }

    mapping(uint256 => Share) public shares;
    mapping(uint256 => bool) public shareRevealed;
    mapping(uint256 => uint256) public shareClaimed;

    event ShareRevealed(Share share);
    event ClaimableMoreThanTotal(uint256 shareId);

    constructor(address _master, IERC20 _token) {
        master = _master;
        token = _token;
    }

    /**
     * @notice Computes the total tokens that should be claimable for a share at the current time.
     * @param _shareId ID of the share.
     * @return owner The owner address of the share.
     * @return claimable Total amount that *should* have been emitted so far.
     * @return total Total cap for this share.
     */
    function calculateClaimable(uint256 _shareId) public view returns (address, uint256, uint256) {
        Share storage share = shares[_shareId];
        uint256 claimable = 0;

        for (uint256 i = 0; i < share.sharpEmissions.length; i++) {
            SharpEmission storage sharpEmission = share.sharpEmissions[i];
            if (block.timestamp >= sharpEmission.startTime) {
                claimable += sharpEmission.amount;
            }
        }

        if (block.timestamp > share.linearEmissionStartTime) {
            uint256 linearPart = share.linearEmissionCoinPerSecond * (block.timestamp - share.linearEmissionStartTime);
            if (linearPart > share.linearEmissionCap) {
                linearPart = share.linearEmissionCap;
            }
            claimable += linearPart;
        }

        return (share.owner, claimable, share.total);
    }

    /**
     * @notice Reveals a new share. Requires a valid signature from the master.
     * @param _share      Full Share struct (may include dynamic array).
     * @param _signature  Master signature for this Share.
     */
    function reveal(Share calldata _share, bytes calldata _signature) external {
        require(!shareRevealed[_share.id], "Share already revealed!");

        bytes memory abiShare = abi.encode(_share);

        bytes32 messageHash = keccak256(abiShare).toEthSignedMessageHash();
        address signer = messageHash.recover(_signature);
        require(signer == master, "Not signed by master!");

        shares[_share.id] = _share;
        shareRevealed[_share.id] = true;
    }

    /**
     * @notice Claims any unclaimed portion of a share’s emission.
     * @param _shareId Share identifier.
     */
    function trigger(uint256 _shareId) external nonReentrant {
        require(shareRevealed[_shareId], "Share not revealed!");

        (address owner, uint256 claimable, uint256 total) = calculateClaimable(_shareId);

        if (claimable > total) {
            claimable = total;
            emit ClaimableMoreThanTotal(_shareId); // Report malfunction
        }

        require(claimable > shareClaimed[_shareId], "Nothing to claim!");

        uint256 amount = claimable - shareClaimed[_shareId];
        shareClaimed[_shareId] += amount;
        require(shareClaimed[_shareId] <= total, "Can't claim more than total!");

        token.safeTransfer(owner, amount);
    }
}
