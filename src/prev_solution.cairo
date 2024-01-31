#[starknet::interface]
trait IAccount<T> {
    fn public_key(self: @T) -> felt252;
    fn is_valid_signature(self: @T, hash: felt252, signature: Array<felt252>) -> felt252;
    fn __execute__(self: @T);
    fn __validate__(self: @T);
}

#[starknet::contract(account)]
mod Account {
    use super::IAccount;
    use starknet::VALIDATED;
    use ecdsa::check_ecdsa_signature;

    #[storage]
    struct Storage {
        public_key: felt252
    }

    #[constructor]
    fn constructor(ref self: ContractState, public_key: felt252) {
        self.public_key.write(public_key);
    }

    #[abi(embed_v0)]
    impl AccountImpl of IAccount<ContractState> {
        fn public_key(self: @ContractState) -> felt252 {
            self.public_key.read()
        }

        fn is_valid_signature(self: @ContractState, hash: felt252, signature: Array<felt252>) -> felt252 {
            let is_valid_length = signature.len() == 2_u32;
            if !is_valid_length {
                return 0;
            }
            let is_valid = check_ecdsa_signature(
                hash, self.public_key.read(), *signature.at(0_u32), *signature.at(1_u32)
            );
            if is_valid { VALIDATED } else { 0 }
        }

        fn __execute__(self: @ContractState){}
        fn __validate__(self: @ContractState){}
    }
}