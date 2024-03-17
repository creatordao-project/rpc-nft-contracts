// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "erc721a/contracts/ERC721A.sol";

error NotAuthorized();
error AlreadyMinted();
error NotMintPeriod();
error AllMinted();

contract ReadyPlayerClub is ERC721A, Ownable {
    /**
     * @dev token metadata link
     */
    string internal _baseUri;
    /**
     * @dev mint start time
     */
    uint256 public MINT_START_TIME;
    /**
     * @dev mint end time
     */
    uint256 public MINT_END_TIME;
    /**
     * @dev total supply
     */
    uint256 constant MAX_TOTAL_SUPPLY = 200;
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

    constructor(
        string memory name_,
        string memory symbol_,
        bytes32 merkleRoot_, 
        address initialOwner_
    ) ERC721A(name_, symbol_) Ownable(initialOwner_) {
        _whitelistMerkleRoot = merkleRoot_;
        MINT_START_TIME = block.timestamp;
        MINT_END_TIME = block.timestamp + 30 days;
    }

    /**
     * @dev mint NFT
     * @param merkleProof_ merkle proof
     */
    function mint(
        uint256 amount_,
        bytes32[] calldata merkleProof_
    ) public returns (bool) {
        if (isValidProof(_msgSender(), amount_, merkleProof_) == false)
            revert NotAuthorized();
        if (
            block.timestamp < MINT_START_TIME || MINT_END_TIME < block.timestamp
        ) revert NotMintPeriod();
        if (minted[_msgSender()] == true) revert AlreadyMinted();
        if (MAX_TOTAL_SUPPLY == totalSupply()) revert AllMinted();

        minted[_msgSender()] = true;
        if (MAX_TOTAL_SUPPLY <= totalSupply() + amount_) {
            _mint(_msgSender(), MAX_TOTAL_SUPPLY - totalSupply());
        } else {
            _mint(_msgSender(), amount_);
        }

        return true;
    }

    /**
     * @dev burn NFT
     * @param tokenId_ burn tokenId
     */
    function burn(uint256 tokenId_) public {
        _burn(tokenId_, true);
    }

    /**
     * @dev setting up baseURI
     * @param uri_ baseURI
     */
    function setBaseURI(string memory uri_) external onlyOwner {
        _baseUri = uri_;

        emit UpdateBaseURI(uri_);
    }

    /**
     * @dev setting up mintable end-time
     * @param newTime_ new end-time
     */
    function setMintStartTime(uint256 newTime_) external onlyOwner {
        MINT_START_TIME = newTime_;
    }

    /**
     * @dev setting up mintable end-time
     * @param newTime_ new end-time
     */
    function setMintEndTime(uint256 newTime_) external onlyOwner {
        if (newTime_ < MINT_START_TIME) revert();

        MINT_END_TIME = newTime_;
    }

    /**
     * @dev update whitelist
     */
    function updateWhitelisteMerkleTree(bytes32 root_) external onlyOwner {
        if (_whitelistMerkleRoot != root_) {
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
        uint256 amount_,
        bytes32[] calldata merkleProof_
    ) public view returns (bool) {
        bytes32 leaf = keccak256(abi.encodePacked(user_, amount_));
        return MerkleProof.verify(merkleProof_, _whitelistMerkleRoot, leaf);
    }
}
