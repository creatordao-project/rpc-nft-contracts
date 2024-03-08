// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

error NotAuthorized();
error AlreadyMinted();
error NotMintTime();

contract ReadyPlayerClub is ERC721, Ownable, ReentrancyGuard {
    /**
     * @dev token metadata link
     */
    string internal _baseUri;
    /**
     * @dev next mint-able token id
     */
    uint256 internal _nextTokenId;
    /**
     * @dev mint start time
     */
    uint256 constant MINT_START_TIME = 0;
    /**
     * @dev mint end time
     */
    uint256 public MINT_END_TIME;
    /**
     * @dev record whitelisted user
     */
    bytes32 internal _whitelistMerkleRoot;
    
    /**
     * @dev prevent duplicate mint
     */
    mapping(address => bool) public minted;

    event UpdateBaseURI(string _uri);
    event UpdateWhitelistMerkleTreeRoot(bytes32 _root);

    constructor(string memory name_, string memory symbol_, bytes32 merkleRoot_, address initialOwner_) ERC721(name_, symbol_) Ownable(initialOwner_){
        _whitelistMerkleRoot = merkleRoot_;
        MINT_END_TIME = block.timestamp + 7 days;
    }

    /**
     * @dev mint NFT
     * @param merkleProof_ merkle proof
     */
    function mint(bytes32[] calldata merkleProof_) public nonReentrant returns (uint256) {
        if (isValidProof(_msgSender(), merkleProof_) == false) revert NotAuthorized();
        if (minted[_msgSender()] == true) revert AlreadyMinted();
        minted[_msgSender()] = true;
        uint256 tokenId = _nextTokenId++;
         _mint(_msgSender(), tokenId);

        return tokenId;
    }

    /**
     * @dev setting up base URI
     * @param uri_ new URI
     */
    function setBaseURI(string memory uri_) external onlyOwner {
        _baseUri = uri_;

        emit UpdateBaseURI(uri_);
    }

    /**
     * @dev setting up mint end time
     * @param time_ new end time
     */
    function setMintEndTime(uint256 time_) external onlyOwner {
        if(time_ < MINT_START_TIME) revert();
        MINT_END_TIME = time_;
    }

    /**
     * @dev update whitelist
     */
    function updateWhitelisteMerkleTree(bytes32 root_) external onlyOwner {
        if(_whitelistMerkleRoot != root_) {
            _whitelistMerkleRoot = root_;

            emit UpdateWhitelistMerkleTreeRoot(root_);
        }
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