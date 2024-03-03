// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

error NotAuthorized();
error AleadyMinted();

contract ReadyPlayerClub is ERC721, Ownable {
    /**
     * @dev token metadata link
     */
    string internal _baseUri;
        /**
     * @dev next mintable token id
     */
    uint256 internal _nextTokenId;
    /**
     * @dev record whitelisted user
     */
    bytes32 internal _whitelistMerkleRoot;
    /**
     * @dev prevent duplicate mint
     */
    mapping(address => bool) public minted;

    event UpdateWhitelistMerkleTreeRoot(bytes32 _root);

    constructor(string memory name_, string memory symbol_, bytes32 merkleRoot_, address initialOwner_) ERC721(name_, symbol_) Ownable(initialOwner_){
        _whitelistMerkleRoot = merkleRoot_;
    }

    /**
     * @dev mint NFT
     * @param merkleProof_ merkle proof
     */
    function mint(bytes32[] calldata merkleProof_) public returns (uint256) {
        if (isValidProof(_msgSender(), merkleProof_) == false) revert NotAuthorized();
        if (minted[_msgSender()] == true) revert AleadyMinted();
        minted[_msgSender()] = true;
        uint256 tokenId = _nextTokenId++;
         _mint(_msgSender(), tokenId);

        return tokenId;
    }

    /**
     * @dev setting up base URI
     * @param _uri new URI
     */
    function setBaseURI(string memory _uri) external onlyOwner {
        _baseUri = _uri;
    }
    /**
     * @dev update whitelist
     */
    function updateWhitelisteMerkleTree(bytes32 _root) external onlyOwner {
        _whitelistMerkleRoot = _root;

        emit UpdateWhitelistMerkleTreeRoot(_root);
    }

    //--------------------------- INTERNAL FUNCTION ----------------------------------------
    function _baseURI() internal view override returns (string memory) {
        return _baseUri;
    }

    //--------------------------- VIEW FUNCTION ----------------------------------------
    function isValidProof(
        address user_,
        bytes32[] calldata merkleProof_
    ) public view returns (bool) {
        bytes32 leaf = keccak256(abi.encodePacked(user_));
        return
            MerkleProof.verify(merkleProof_, _whitelistMerkleRoot, leaf);
    }

    function totalSupply() public view returns (uint256) {
        return _nextTokenId;
    }
}