program aleo_nft.aleo;

record NFTRecord:
    owner as address.private;
    token_data as field.private;


mapping available_nfts:
	key as field.public;
	value as u128.public;


mapping nft_owner:
	key as address.public;
	value as field.public;

function initialize:
    input r0 as field.private;
    input r1 as u128.private;
    assert.eq self.caller aleo1jzpc5zt796fz3a6dlsyfq5mlnhuemmwcw43x42duksw5ldx6ds8qtqndpd;
    async initialize r0 r1 into r2;    output r2 as aleo_nft.aleo/initialize.future;

finalize initialize:
    input r0 as field.public;
    input r1 as u128.public;
    set r1 into available_nfts[r0];


function mint:
    input r0 as address.private;
    input r1 as field.private;
    cast r0 r1 into r2 as NFTRecord.record;
    async mint r1 into r3;    output r2 as NFTRecord.record;
    output r3 as aleo_nft.aleo/mint.future;

finalize mint:
    input r0 as field.public;
    get.or_use available_nfts[r0] 0u128 into r1;
    sub r1 1u128 into r2;
    set r2 into available_nfts[r0];


function transfer_private:
    input r0 as NFTRecord.record;
    input r1 as address.private;
    cast r1 r0.token_data into r2 as NFTRecord.record;
    output r2 as NFTRecord.record;


function convert_private_to_public:
    input r0 as NFTRecord.record;
    async convert_private_to_public self.caller r0.token_data into r1;    output r1 as aleo_nft.aleo/convert_private_to_public.future;

finalize convert_private_to_public:
    input r0 as address.public;
    input r1 as field.public;
    set r1 into nft_owner[r0];


function convert_public_to_private:
    input r0 as field.private;
    cast self.caller r0 into r1 as NFTRecord.record;
    async convert_public_to_private self.caller r0 into r2;    output r1 as NFTRecord.record;
    output r2 as aleo_nft.aleo/convert_public_to_private.future;

finalize convert_public_to_private:
    input r0 as address.public;
    input r1 as field.public;
    get nft_owner[r0] into r2;
    assert.eq r2 r1;
    remove nft_owner[r0];


function transfer_public:
    input r0 as address.private;
    input r1 as field.private;
    async transfer_public self.caller r0 r1 into r2;    output r2 as aleo_nft.aleo/transfer_public.future;

finalize transfer_public:
    input r0 as address.public;
    input r1 as address.public;
    input r2 as field.public;
    get nft_owner[r0] into r3;
    assert.eq r3 r2;
    remove nft_owner[r0];
    set r2 into nft_owner[r1];
