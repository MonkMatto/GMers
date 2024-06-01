// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

/// This was quickly hacked together from thirdweb contracts, which are Apache-2.0 licensed
/// hackjob by Matto ;)
contract AirdropERC1155 {

    /**
     *  @notice Details of amount and recipient for airdropped token.
     *
     *  @param recipient The recipient of the tokens.
     *  @param tokenId ID of the ERC1155 token being airdropped.
     *  @param amount The quantity of tokens to airdrop.
     */
    struct AirdropData {
        address recipient;
        uint256 tokenId;
        uint256 amount;
    }

    /// @notice Emitted when an airdrop fails for a recipient address.
    event AirdropFailed(
        address indexed tokenAddress,
        address indexed tokenOwner,
        address indexed recipient,
        uint256 tokenId,
        uint256 amount
    );

    /**
     *  @notice          Lets contract-owner send ERC1155 tokens to a list of addresses.
     *  @dev             The token-owner should approve target tokens to Airdrop contract,
     *                   which acts as operator for the tokens.
     *
     *  @param _tokenAddress    The contract address of the tokens to transfer.
     *  @param _tokenOwner      The owner of the tokens to transfer.
     *  @param _data        List containing recipient, tokenId and amounts to airdrop.
     */
    function airdropERC1155(
        address _tokenAddress,
        address _tokenOwner,
        AirdropData[] calldata _data
    ) external {

        uint256 len = _data.length;

        for (uint256 i = 0; i < len; ) {
            try
                IERC1155(_tokenAddress).safeTransferFrom(
                    _tokenOwner,
                    _data[i].recipient,
                    _data[i].tokenId,
                    _data[i].amount,
                    ""
                )
            {} catch {
                // revert if failure is due to unapproved tokens
                require(
                    IERC1155(_tokenAddress).balanceOf(_tokenOwner, _data[i].tokenId) >= _data[i].amount &&
                        IERC1155(_tokenAddress).isApprovedForAll(_tokenOwner, address(this)),
                    "Not balance or approved"
                );

                emit AirdropFailed(
                    _tokenAddress,
                    _tokenOwner,
                    _data[i].recipient,
                    _data[i].tokenId,
                    _data[i].amount
                );
            }

            unchecked {
                i += 1;
            }
        }
    }
}