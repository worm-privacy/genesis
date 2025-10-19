# 1. Generate a private/public key (Report public key)
# 2. Read from a CSV file (Address/Amount/Cliff/Vesting)
# 3. Sign (Address/Amount/Cliff/Vesting) pair
# 4. Export (Address/Amount/Cliff/Vesting/Signature) in a file

# Contract:
# Constructor(pubKey)
#   Store pubkey
# 
# getCoins(address/amount/cliff/vesting/signature)
#   Verify signature is valid for address amount (With stored pub key)
#   Disallow same address mintin twice
#   If everything ok: transfer WORM to address

# We also want tests