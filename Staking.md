## Validators
- added with Proof-of-Stake
- rewarded for:
    - attesting and proposing blocks on time
    - participating in sync committee
    - priority fees for faster inclusion - individual transactions can have special fees to execute them faster
- penalized for:
    - being offline etc.

### Key management
- private key to generate the validator keys
    - as long as you have it you can regenerate the validator keys over and over again
    - mnemonic phrase used to generate as many keystores as you want

After generating the keys for validator:
- deposit data: general data about debosit data which you upload to launchpad
- keystore data upload to node
    - path part specifies the number of specific operations that were done on original key to derive validator key

- after depositing, we need to wait for 16-24 hours for the network to accept the validator
- validator checklist: https://holesky.launchpad.ethereum.org/en/checklist/

# TODO
- mnemonic phrase in generating validator keys, why do we use it?
    - look at the generation proces how it is done?