// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MemeGallery {
    struct Meme {
        uint256 id;
        string uri;
        address payable creator;
        uint256 price;
        bool forSale;
    }

    mapping(uint256 => Meme) public memes;
    uint256 public memeCount;
    address public owner;

    event MemeCreated(uint256 id, string uri, address creator);
    event MemeForSale(uint256 id, uint256 price);
    event MemeSold(uint256 id, address buyer, uint256 price);
    event MemeShared(uint256 id, address sharer);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action.");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function createMeme(string memory _uri, uint256 _price) public {
        memeCount++;
        memes[memeCount] = Meme(memeCount, _uri, payable(msg.sender), _price, false);
        emit MemeCreated(memeCount, _uri, msg.sender);
    }

    function putMemeForSale(uint256 _id, uint256 _price) public {
        Meme storage meme = memes[_id];
        require(msg.sender == meme.creator, "You are not the creator of this meme.");
        meme.forSale = true;
        meme.price = _price;
        emit MemeForSale(_id, _price);
    }

    function buyMeme(uint256 _id) public payable {
        Meme storage meme = memes[_id];
        require(meme.forSale, "This meme is not for sale.");
        require(msg.value >= meme.price, "Insufficient payment.");
        
        meme.creator.transfer(msg.value);
        meme.forSale = false;
        meme.creator = payable(msg.sender);
        emit MemeSold(_id, msg.sender, msg.value);
    }

    function shareMeme(uint256 _id) public {
        Meme storage meme = memes[_id];
        require(bytes(meme.uri).length > 0, "Meme does not exist.");
        emit MemeShared(_id, msg.sender);
    }
}

