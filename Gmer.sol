// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";

/// @custom:security-contact monkmatto@protonmail.com
contract GMer is ERC1155, Ownable(msg.sender), ERC1155Supply, ERC2981 {
    constructor()
    ERC1155("GMer") {}

    bool public isAirdropMinted;
    bool public isSaleActive;
    address public fundsReceiver; // 0x5969b0bFDEf98B570C2EFb28787B1C9d1bBC59C9 // liquid splits receiver
    uint256 public cost = 0.0001 ether;
    string[] public uris;

    function getURIs() public view returns (string[] memory) {
        return uris;
    }

    function mint(address account, uint256 amount)
        public
        payable
    {
        if (msg.sender != owner()) {
            require(msg.value == cost * amount, "Gmers: MATHS IS HARD");
        } else {
            require(!isAirdropMinted, "Gmers: Airdrop already preminted");
            isAirdropMinted = true;
            isSaleActive = true;
        }
        require(isSaleActive, "Gmers: Sale is closed");
        _mint(account, 0, amount, "");
    }

    function addURI(string memory _uri) public onlyOwner {
        uris.push(_uri);
    }

    function editURI(uint256 index, string memory _uri) public onlyOwner {
        uris[index] = _uri;
    }

    function closeSaleAndCapSupply() public onlyOwner {
        isSaleActive = false;
    }

    function withdraw() public onlyOwner {
        require(fundsReceiver != address(0), "Gmers: No funds receiver set");
        payable(fundsReceiver).transfer(address(this).balance);
    }

    // The following functions are overrides required by Solidity.

    function uri(uint256 id)
        public
        view
        override(ERC1155)
        returns (string memory)
    {
        return uris[(block.timestamp / 3600) % uris.length];
    }

    function setFundsReceiver(address _fundsReceiver, uint96 royaltyBPS) public onlyOwner {
        require(royaltyBPS <= 500, "Gmers: Royalty BPS too high");
        require(_fundsReceiver != address(0), "Gmers: Funds receiver cannot be 0x0");
        fundsReceiver = _fundsReceiver;
        _setDefaultRoyalty(_fundsReceiver, royaltyBPS);
    }

    function _update(address from, address to, uint256[] memory ids, uint256[] memory values)
        internal
        override(ERC1155, ERC1155Supply)
    {
        super._update(from, to, ids, values);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC1155, ERC2981)
        returns (bool)
    {
    return
        ERC1155.supportsInterface(interfaceId) ||
        ERC2981.supportsInterface(interfaceId) ||
        super.supportsInterface(interfaceId);
    }
}
