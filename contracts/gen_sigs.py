# 1. Generate a private/public key (Report public key)
# 2. Read from a CSV file (Address/Amount)
# 3. Sign (Address/Amount) pair
# 4. Export (Address/Amount/Signature) in a file

# Contract:
# Constructor(pubKey)
#   Store pubkey
# 
# getCoins(address/amount/signature)
#   Verify signature is valid for address amount (With stored pub key)
#   Disallow same address mintin twice
#   If everything ok: transfer WORM to address

# We also want tests