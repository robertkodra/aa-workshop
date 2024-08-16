use core::option::OptionTrait;
use starknet::ContractAddress;
use snforge_std::signature::KeyPairTrait;
use snforge_std::signature::stark_curve::{
    StarkCurveKeyPairImpl, StarkCurveSignerImpl, StarkCurveVerifierImpl
};
use snforge_std::{start_cheat_caller_address, stop_cheat_caller_address, cheat_execution_info};
use aa::account::{IAccountDispatcher, IAccountDispatcherTrait};
use super::utils::{deploy_contract, create_call_array_mock, create_tx_info_mock};
use snforge_std::{cheatcodes::execution_info::{ExecutionInfoMock, BlockInfoMock, BlockInfoMockImpl, Operation, CheatArguments}};

#[test]
fn accept_valid_tx_signature() {
    let mut signer = KeyPairTrait::<felt252, felt252>::from_secret_key(123);

    let contract_address = deploy_contract(signer.public_key);
    let dispatcher = IAccountDispatcher { contract_address };

    let tx_hash_mock = 123;
    let tx_version_mock = 1;
    let tx_info_mock = create_tx_info_mock(tx_hash_mock, ref signer, tx_version_mock);

    let call_array_mock = create_call_array_mock();
    let zero_address: ContractAddress = 0.try_into().unwrap();
    let execution_info_mock = ExecutionInfoMock{block_info: BlockInfoMockImpl::default(), tx_info: tx_info_mock, caller_address: Operation::StartGlobal(contract_address)};

    start_cheat_caller_address(contract_address, zero_address);
    cheat_execution_info(execution_info_mock);
    dispatcher.__validate__(call_array_mock);
}

#[test]
#[should_panic]
fn reject_invalid_tx_signature() {
    let mut signer = KeyPairTrait::<felt252, felt252>::from_secret_key(123);
    let contract_address = deploy_contract(signer.public_key);
    let dispatcher = IAccountDispatcher { contract_address };

    let tx_hash_mock = 123;
    let mut hacker = KeyPairTrait::<felt252, felt252>::from_secret_key(456);
    let tx_version_mock = 1;
    let tx_info_mock = create_tx_info_mock(tx_hash_mock, ref hacker, tx_version_mock);
    let call_array_mock = create_call_array_mock();
    let zero_address: ContractAddress = 0.try_into().unwrap();
    let execution_info_mock = ExecutionInfoMock{block_info: BlockInfoMockImpl::default(), tx_info: tx_info_mock, caller_address: Operation::StartGlobal(contract_address)};

    start_cheat_caller_address(contract_address, zero_address);
    cheat_execution_info(execution_info_mock);
    dispatcher.__validate__(call_array_mock);

}
