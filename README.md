# mini-game-proposal
## Setup environment:
- $ mkdir new_folder
- $ cd new_folder
- $ git clone https://github.com/charles-seteda/mini-game-proposal.git
- $ cd mini-game-proposal
- $ touch .env
### Create .env file:
<p>
RPC_ENDPOINT_BSC_TESTNET=https://data-seed-prebsc-2-s2.bnbchain.org:8545
RPC_ENDPOINT_BSC_MAINNET=https://bsc-dataseed.bnbchain.org/
RPC_ENDPOINT_ETH=
RPC_ENDPOINT_SEPOLIA=https://eth-sepolia.g.alchemy.com/v2/<Your_API_Key>
RPC_ENDPOINT_HEDERA_TESTNET=https://testnet.hashio.io/api/
</p>

<p>
PRIVATE_KEY_DEPLOYED=[Your_Metamask_Private_Key]

DEFAULT_NETWORK=bscTestnet

ETHERSCAN_API_KEY_TESTNET=[Your_Testnet_Api_Key]

ETHERSCAN_API_KEY_BSC_TESTNET=[Your_Testnet_Api_Key]
</p>
 

## Build:
- $ yarn install
- $ npx hardhat compile
## Deploy:
- $ npx hardhat run  scripts/deployToken.ts --network bscTestnet
- $ npx hardhat run  scripts/deployMiniGame.ts --network bscTestnet
## Upgrade:
- $ npx hardhat run  scripts/deployMiniGame_Upgrade.ts --network bscTestnet

## Current version on the BSC testnet:
|     Contract     |                  Address                   |
|:----------------:|:------------------------------------------:|
|   CharlesToken   | 0xF92bc45127ca1ed820aAE5CB6E58248cd383cF76 |
| MiniGameProposal | 0xF92bc45127ca1ed820aAE5CB6E58248cd383cF76 |

