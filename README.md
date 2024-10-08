# Starknet’s Account Abstraction Workshop

In this workshop you will learn how to create an account contract with a single signer that uses the STARK-friendly elliptic curve to sign transactions. The final code is inspired by Open Zeppelin’s account contract.

After completing each step, run the associated script to verify it has been implemented correctly.

Use the [Cairo book](https://book.cairo-lang.org/ch00-00-introduction.html) and the [Starknet docs](https://docs.starknet.io/documentation/) as a reference.

## Setup

1. Clone this repository
1. Create a new file called `account.cairo` inside the `src` folder
1. Copy the following starting code into the file

```rust
#[starknet::interface]
trait IAccount<T> {
    fn __execute__(self: @T);
    fn __validate__(self: @T);
}

#[starknet::contract(account)]
mod account {
    use super::IAccount;

    #[storage]
    struct Storage {}

    #[abi(embed_v0)]
    impl AccountImpl of IAccount<ContractState> {
        fn __execute__(self: @ContractState){}
        fn __validate__(self: @ContractState){}
    }
}
```

> **Note:** You'll be working on the `account.cairo` file to complete the requirements of each step. The file `prev_solution.cairo` will show up in future steps as a way to catch up with the workshop if you fall behind. **Don't modify that file**.

The next setup steps will depend on wether you prefer using Docker to manage global dependencies or not.

### Option 1: Without Docker

1. Install `asdf` ([instructions](https://asdf-vm.com/guide/getting-started.html))
2. Install Scarb `2.7.0` via `asdf` ([instructions](https://docs.swmansion.com/scarb/download.html#install-via-asdf))
3. Install Starknet Foundry `0.27.0` via `asdf` ([instructions](https://foundry-rs.github.io/starknet-foundry/getting-started/installation.html))
4. Install the Cairo 1.0 extension for VSCode ([marketplace](https://foundry-rs.github.io/starknet-foundry/getting-started/installation.html#installation-via-asdf))
5. Install Nodejs 20 or higher ([instructions](https://nodejs.org/en/))
6. Run the tests to verify the project is setup correctly

```
$ scarb test
```

## Step 1

Checkout the `step1` branch to enable the verification tests for this section.

```
$ git checkout -b step1 origin/step1
```

### Goal

Collect the `public_key` associated with a signer that is passed to the `constructor`, and make it public through a function also called `public_key`.

### Verification

When completed, execute the test suite to verify you've met all the requirements for this section.

```
$ scarb test
```

### Hints

- A `public_key` is defined with a single felt

## Step 2

Checkout the `step2` branch to enable the verification tests for this section.

```
$ git checkout -b step2 origin/step2
```

If you fell behind, the file `prev_solution.cairo` contains the solution to the previous step.

### Goal

Implement the function `is_valid_signature` as defined by the [SNIP-6](https://github.com/starknet-io/SNIPs/blob/main/SNIPS/snip-6.md) standard.

### Requirements

- If the signature was created by the signer associated with the account contract the function should return the short string `'VALID'`.
- If the signature was created by a signer not associated with the account contract, the function should return any other felt that is not the short string `'VALID'`.

### Verification

When completed, execute the test suite to verify you've met all the requirements for this section.

```
$ scarb test
```

### Hints

- Use the stored `public_key` to check the signature.
- A "short string" is just an ascii representation of a single felt.
- You can check signatures on the STARK-friendly curve with the syscall `check_ecdsa_signature` available in the `ecdsa` module.
- The short string `'VALID'` can be hardcoded or read from the module `starknet::VALIDATED`.

## Step 3

Checkout the `step3` branch to enable the verification tests for this section.

```
$ git checkout -b step3 origin/step3
```

If you fell behind, the file `prev_solution.cairo` contains the solution to the previous step.

### Goal

Implement the function `__validate__` as defined by the [SNIP-6](https://github.com/starknet-io/SNIPs/blob/main/SNIPS/snip-6.md) standard. This function is similar to `is_valid_signature` but instead of expecting the signature to be passed as an argument it verifies the transaction's signature.

### Requirements

- If the transaction signature was created by the signer associated with the account contract the function should return the short string `'VALID'`.
- If the transaction signature was created by a signer not associated with the account contract, the transaction should be halted and reverted with an error message.

### Verification

When completed, execute the test suite to verify you've met all the requirements for this section.

```
$ scarb test
```

### Hints

- You can read the transaction details which includes the transaction signature using the syscall `get_tx_info` from the `starknet` module.
- You can stop and revert a transaction with an error message using the `assert` function.
- The `Call` struct can be found in the module `starknet::account`.

## Step 4

Checkout the `step4` branch to enable the verification tests for this section.

```
$ git checkout -b step4 origin/step4
```

If you fell behind, the file `prev_solution.cairo` contains the solution to the previous step.

### Goal

Protect the `__validate__` function by making it callable only by the protocol which uses the zero address.

### Requirements

- If the function is invoked by any other address, the transaction should be halted and reverted with an error message.

### Verification

When completed, execute the test suite to verify you've met all the requirements for this section.

```
$ scarb test
```

### Hints

- You can read who the caller is by using the syscall `get_caller_address` available in the `starknet` module.

## Step 5

Checkout the `step5` branch to enable the verification tests for this section.

```
$ git checkout -b step5 origin/step5
```

If you fell behind, the file `prev_solution.cairo` contains the solution to the previous step.

### Goal

Implement the functions `__validate_declare__` and `__validate_deploy__` with the exact same logic as `__validate__` and make them publicly accessible. The signature of both functions is shown below.

```rust
fn __validate_declare__(
    self: @ContractState,
    class_hash: felt252
) -> felt252

fn __validate_deploy__(
    self: @ContractState,
    class_hash: felt252,
    salt: felt252,
    public_key: felt252
) -> felt252
```

### Requirements

- The return value of both functions is the same as `__validate__` (`'VALID'` or halted transaction).
- Both functions should only be callable by the Starknet protocol (same as `__validate__`).

### Verification

When completed, execute the test suite to verify you've met all the requirements for this section.

```
$ scarb test
```

### Hints

- Create a private function to encapsulate the logic of `__validate__` so it can be reused by `__validate_declare__` and `__validate_deploy__`.
- By grouping private functions into its own trait they can be called as methods of `self` and the smart contract state doesn’t need to be explicitly passed.
- You can auto generate a trait from an implementation using the attribute `generate_trait`.

## Step 6

Checkout the `step6` branch to enable the verification tests for this section.

```
$ git checkout -b step6 origin/step6
```

If you fell behind, the file `prev_solution.cairo` contains the solution to the previous step.

### Goal

Implement the function `__execute__` as defined by the [SNIP-6](https://github.com/starknet-io/SNIPs/blob/main/SNIPS/snip-6.md) standard.

### Requirements

- The function should be able to handle a single contract call or multiple contract calls in sequence.
- The result of each call should be collected and returned as an array.
- If an empty array of calls is passed, the function should halt and revert the transaction.
- The function should only be called by the protocol (the zero address).

### Verification

When completed, execute the test suite to verify you've met all the requirements for this section.

```
$ scarb test
```

### Hints

- You can call other contracts using the low level syscall `call_contract_syscall` available in the `starknet` module.
- You can iterate over an array by using the `loop` keyword and the array method `pop_front`.

## Step 7

Checkout the `step7` branch to enable the verification tests for this section.

```
$ git checkout -b step7 origin/step7
```

If you fell behind, the file `prev_solution.cairo` contains the solution to the previous step.

### Goal

Implement the function `supports_interface` from the [SNIP-5](https://github.com/starknet-io/SNIPs/blob/main/SNIPS/snip-5.md) standard for the [SNIP-6](https://github.com/starknet-io/SNIPs/blob/main/SNIPS/snip-6.md) interface.

### Requirements

- When providing the `interface_id` of the SNIP-6 trait the function should return `true`.
- When providing any other value for `interface_id` the function should return `false`.

### Verification

When completed, execute the test suite to verify you've met all the requirements for this section.

```
$ scarb test
```

### Hints

- The `interface_id` of the SNIP-6 trait is `1270010605630597976495846281167968799381097569185364931397797212080166453709`

## Step 8

Checkout the `step8` branch to enable the verification tests for this section.

```
$ git checkout -b step8 origin/step8
```

If you fell behind, the file `prev_solution.cairo` contains the solution to the previous step.

### Goal

Limit execution of the functions `__execute__`, `__validate__`, `__validate_declare__` and `__validate_deploy__` to transactions of the [latest version](https://docs.starknet.io/documentation/architecture_and_concepts/Network_Architecture/transactions/).

### Requirements

- Attempting to execute an `invoke`, `declare`, and `deploy_account` transaction that is not of the latest version should result in the transaction being halted and reverted.
- Simulated transactions should be supported.

### Verification

When completed, execute the test suite to verify you've met all the requirements for this section.

```
$ scarb test
```

### Hints

- Simulated transactions use the same version as their real counterpart but offset by `2^128`.

If the test suite passes, congratulations, you have created your first custom Starknet account contract thanks to account abstraction!

To deploy your account contract to testnet we will use [`starknet.js`](https://www.starknetjs.com/).

## Step 9A (Typescript)

Checkout the `step9-js` branch to get a deployment script based on [`starknet.js`](https://www.starknetjs.com/).

```
$ git checkout -b step9-js origin/step9-js
```

If you fell behind, the file `prev_solution.cairo` contains the solution to the previous step.

### Goal

To deploy your account contract to Starknet's testnet using the `deploy.ts` script found in the `scripts` folder.

### Dependencies

Run the command below from the project's root folder to install the deployment script dependencies.

```
$ npm install
```

### Deployer Wallet

Create a wallet that the script can use to pay for the declaration of your account contract.

#### Steps

1. Create a wallet on Starknet **testnet** using the [Argent X](https://www.argent.xyz/argent-x/) or [Braavos](https://braavos.app/) browser extension.
2. Fund the wallet by using the [Faucet](https://starknet-faucet.vercel.app/).
3. Create a file in the project's root folder called `.env`
4. Export the private key of the funded wallet and paste it in the `.env` file using the key `DEPLOYER_PRIVATE_KEY`.

```
DEPLOYER_PRIVATE_KEY=<YOUR_FUNDED_TESTNET_WALLET_PK>
```

### RPC Endpoint

To successfully deploy the contract with the script on the Starknet Testnet, you will need to provide an RPC URL. For our workshop, we will use Blast's Public RPC Endpoint.

Add the following line in your `.env` file:

```bash
RPC_ENDPOINT=https://starknet-sepolia.public.blastapi.io/rpc/v0_7
```

Now, your `.env` file should look like this:

```
DEPLOYER_PRIVATE_KEY=<YOUR_FUNDED_TESTNET_WALLET_PK>
RPC_ENDPOINT=https://starknet-sepolia.public.blastapi.io/rpc/v0_7
```

### Run the Script

Run the script that will declare, deploy and use your account contract to send a small amount of ETH to another wallet as a test.

#### Steps

1. From project's root folder run `npm run deploy`
1. Follow the instructions from the terminal

If the script finishes successfully your account contract is ready to be used on Starknet testnet.
