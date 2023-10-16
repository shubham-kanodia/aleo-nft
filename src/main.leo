// The 'aleo_nft' program.

program aleo_nft.aleo {
    record NFTRecord {
        owner: address,
        token_data: field
    }

    mapping available_nfts: field => u128;

    // Limitation: An NFT owner can only own one NFT publicly
    mapping nft_owner: address => field;

    // Create NFT
    transition initialize(token_data: field, amount: u128) {
        assert_eq(self.caller, aleo1jzpc5zt796fz3a6dlsyfq5mlnhuemmwcw43x42duksw5ldx6ds8qtqndpd);

        return then finalize(token_data, amount);
    }

    finalize initialize (token_data: field, amount: u128) {
        Mapping::set(available_nfts, token_data, amount);
    }

    transition mint(to: address, token_data: field) -> NFTRecord {
        let nft: NFTRecord = NFTRecord {
            owner: to,
            token_data: token_data
        };

        return nft then finalize(token_data);
    }

    finalize mint (token_data: field) {
        let nfts_count: u128 = Mapping::get_or_use(available_nfts, token_data, 0u128);
        Mapping::set(available_nfts, token_data, nfts_count - 1u128);
    }

    transition transfer_private(nft: NFTRecord, to: address) -> NFTRecord {
        // The "owner is the one spending the record" check is already done
        // assert_eq(self.caller, nft.owner);

        let new_nft: NFTRecord = NFTRecord {
            owner: to,
            token_data: nft.token_data
        };

        return new_nft;
    }

    transition convert_private_to_public(nft: NFTRecord) {
        return then finalize(self.caller, nft.token_data);
    }

    finalize convert_private_to_public (token_owner: address, token_data: field) {
        Mapping::set(nft_owner, token_owner, token_data);
    }

    transition convert_public_to_private(token_data: field) -> NFTRecord {
        let nft: NFTRecord = NFTRecord {
            owner: self.caller,
            token_data: token_data
        };

        return nft then finalize(self.caller, token_data);
    }

    finalize convert_public_to_private (owner: address, token_data: field) {
        // Check ownership
        let owned_token_data: field = Mapping::get(nft_owner, owner);
        assert_eq(owned_token_data, token_data);

        // Delete public record
        Mapping::remove(nft_owner, owner);
    }

    transition transfer_public(to: address, token_data: field) {
        return then finalize(self.caller, to, token_data);
    }

    finalize transfer_public (from: address, to: address, token_data: field) {
        // Check that caller is the owner
        let caller_owned_token_data: field = Mapping::get(nft_owner, from);
        assert_eq(caller_owned_token_data, token_data);

        // Change ownership
        Mapping::remove(nft_owner, from);
        Mapping::set(nft_owner, to, token_data);
    }
}
