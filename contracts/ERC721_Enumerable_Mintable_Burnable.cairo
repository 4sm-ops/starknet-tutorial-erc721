# SPDX-License-Identifier: MIT
# OpenZeppelin Contracts for Cairo v0.1.0 (token/erc721_enumerable/ERC721_Enumerable_Mintable_Burnable.cairo)

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin
from starkware.cairo.common.uint256 import Uint256

from starkware.starknet.common.syscalls import get_contract_address, get_caller_address

from openzeppelin.token.erc721.library import ERC721
from openzeppelin.token.erc721_enumerable.library import ERC721_Enumerable
from openzeppelin.introspection.ERC165 import ERC165
from openzeppelin.access.ownable import Ownable

from starkware.cairo.common.alloc import alloc

from openzeppelin.security.safemath import SafeUint256

from starkware.cairo.common.math import split_felt

from contracts.token.ERC20.IERC20 import IERC20



const REG_PRICE = 5

# Animals struct to keep characteristics
struct Animal:
    member sex: felt
    member legs: felt
    member wings: felt
end

# Mapping named animals_storage that holds the Animals details for each NFT using his tokenId
@storage_var
func animals_storage(token_id: Uint256) -> (account: Animal):
end

# Keeps a counter of the number of Animals 
@storage_var
func number_of_animals_len() -> (res: Uint256):
end

# Keeps list of breeders 

@storage_var
func breeders_list(account : felt) -> (is_approved : felt):
end


#
# Constructor
#

@constructor
func constructor{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        name: felt,
        symbol: felt,
        owner: felt
    ):
    ERC721.initializer(name, symbol)
    ERC721_Enumerable.initializer()
    Ownable.initializer(owner)
    return ()
end

#
# Getters
#

@view
func get_animal_characteristics{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(tokenId: Uint256) -> (sex : felt, legs : felt, wings : felt):

    let (animal) = animals_storage.read(tokenId)

    return (animal.sex, animal.legs, animal.wings)   
end

@view
func animals_minted{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (res: Uint256):
    
    # get number of existing animals
    let (res: Uint256) = number_of_animals_len.read()

    # assert res > 0
    return (res)
end

@view
func is_breeder{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(account : felt) -> (is_approved : felt):
    
    # get breeder status
    let (is_approved) = breeders_list.read(account)

    return (is_approved)
end


@view
func registration_price{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (price: Uint256):
    
    # convert REG_PRICE to Uint256
    let split = split_felt(REG_PRICE)
    let price = Uint256(low=split.low, high=split.high)

    return (price)
end



@view
func totalSupply{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }() -> (totalSupply: Uint256):
    let (totalSupply: Uint256) = ERC721_Enumerable.total_supply()
    return (totalSupply)
end

@view
func tokenByIndex{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }(index: Uint256) -> (tokenId: Uint256):
    let (tokenId: Uint256) = ERC721_Enumerable.token_by_index(index)
    return (tokenId)
end

@view
func token_of_owner_by_index{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }(account: felt, index: felt) -> (tokenId: Uint256):

    let split = split_felt(index)
    let index_uint = Uint256(low=split.low, high=split.high)

    let (tokenId: Uint256) = ERC721_Enumerable.token_of_owner_by_index(account, index_uint)
    return (tokenId)
end

@view
func supportsInterface{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(interfaceId: felt) -> (success: felt):
    let (success) = ERC165.supports_interface(interfaceId)
    return (success)
end

@view
func name{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (name: felt):
    let (name) = ERC721.name()
    return (name)
end

@view
func symbol{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (symbol: felt):
    let (symbol) = ERC721.symbol()
    return (symbol)
end

@view
func balanceOf{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(owner: felt) -> (balance: Uint256):
    let (balance: Uint256) = ERC721.balance_of(owner)
    return (balance)
end

@view
func ownerOf{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(tokenId: Uint256) -> (owner: felt):
    let (owner: felt) = ERC721.owner_of(tokenId)
    return (owner)
end

@view
func getApproved{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(tokenId: Uint256) -> (approved: felt):
    let (approved: felt) = ERC721.get_approved(tokenId)
    return (approved)
end

@view
func isApprovedForAll{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(owner: felt, operator: felt) -> (isApproved: felt):
    let (isApproved: felt) = ERC721.is_approved_for_all(owner, operator)
    return (isApproved)
end

@view
func tokenURI{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(tokenId: Uint256) -> (tokenURI: felt):
    let (tokenURI: felt) = ERC721.token_uri(tokenId)
    return (tokenURI)
end

@view
func owner{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (owner: felt):
    let (owner: felt) = Ownable.owner()
    return (owner)
end

#
# Externals
#

@external
func approve{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }(to: felt, tokenId: Uint256):
    ERC721.approve(to, tokenId)
    return ()
end

@external
func setApprovalForAll{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(operator: felt, approved: felt):
    ERC721.set_approval_for_all(operator, approved)
    return ()
end

@external
func transferFrom{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }(
        from_: felt,
        to: felt,
        tokenId: Uint256
    ):
    ERC721_Enumerable.transfer_from(from_, to, tokenId)
    return ()
end

@external
func safeTransferFrom{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }(
        from_: felt,
        to: felt,
        tokenId: Uint256,
        data_len: felt,
        data: felt*
    ):
    ERC721_Enumerable.safe_transfer_from(from_, to, tokenId, data_len, data)
    return ()
end

@external
func mint{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }(to: felt, tokenId: Uint256):
#    Ownable.assert_only_owner()
    ERC721_Enumerable._mint(to, tokenId)
    return ()
end

@external
func burn{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }(tokenId: Uint256):
    ERC721.assert_only_token_owner(tokenId)
    ERC721_Enumerable._burn(tokenId)
    return ()
end

@external
func setTokenURI{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }(tokenId: Uint256, tokenURI: felt):
    Ownable.assert_only_owner()
    ERC721._set_token_uri(tokenId, tokenURI)
    return ()
end

@external
func transferOwnership{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(newOwner: felt):
    Ownable.transfer_ownership(newOwner)
    return ()
end

@external
func renounceOwnership{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }():
    Ownable.renounce_ownership()
    return ()
end


@external
func declare_animal{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(sex : felt, legs : felt, wings : felt) -> (token_id : Uint256):
    alloc_locals

    let (sender_address) = get_caller_address()

    # get number of existing animals
    let (n_anim: Uint256) = number_of_animals_len.read()

    # mint new one
    mint(sender_address, n_anim)

    # record parameters
    animals_storage.write(n_anim, Animal(sex=sex, legs=legs, wings=wings))

    # change supply
    let (new_supply: Uint256) = SafeUint256.add(n_anim, Uint256(1, 0))
    number_of_animals_len.write(new_supply)

    return (token_id = n_anim)   
end


@external
func declare_dead_animal{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }(tokenId: Uint256):

    burn(tokenId)

    # record parameters
    animals_storage.write(tokenId, Animal(sex=0, legs=0, wings=0))

    return ()
end


@external
func register_me_as_breeder{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }() -> (is_added : felt):


   # Check that the caller is not zero
    let (caller_address) = get_caller_address()

    # Charge a fee
    let dummy_token_address = 0x07ff0a898530b169c5fe6fed9b397a7bbd402973ce2f543965f99d6d4a4c17b8
    let (contract_address) = get_contract_address()

    let split = split_felt(REG_PRICE)
    let amount = Uint256(low=split.low, high=split.high)

    IERC20.transferFrom(
        contract_address=dummy_token_address,
        sender=caller_address,
        recipient=contract_address,
        amount=amount
    )

    # Register as breeder
    breeders_list.write(account=caller_address, value=1)
    return (is_added=1)
end


