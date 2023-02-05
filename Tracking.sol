// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;
pragma abicoder v2;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Tracking is ERC721URIStorage {
    string getName;
    string getSymbol;

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    
    mapping(uint256 => Register) private idToPost;
    mapping(uint256 => Register) private hashToPost;

    struct Register {
        uint256 idToken;
        address wallet;
        bool SENT;
        bool OPEN;
        bool READ;
        bool FINISHED;
        uint256 lastUpdated;
    }

    event RegisterTrackingSent(address addressWallet, uint256 tokenId, uint256 timestamp);
    event RegisterTrackingOpen(address addressWallet, uint256 tokenId, uint256 timestamp);
    event RegisterTrackingRead(address addressWallet, uint256 tokenId, uint256 timestamp);
    event RegisterTrackingFinished(address addressWallet, uint256 tokenId, uint256 timestamp);

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {
        getName = _name;
        getSymbol = _symbol;
    }

    function mint(address walletAddress, string memory _urlMetaData) payable public returns (uint256) {
        _tokenIds.increment();
        uint256 id = _tokenIds.current();
        _mint(walletAddress, id);
        _setTokenURI(id, _urlMetaData);

        Register storage post = idToPost[id];

        post.idToken = id;
        post.wallet = walletAddress;
        post.SENT = true;
        post.OPEN = false;
        post.READ = false;
        post.FINISHED = false;
        post.lastUpdated = block.timestamp;

        hashToPost[id] = post;

        emit RegisterTrackingSent(walletAddress, id, block.timestamp);
        return id;
    }

    function open(uint256 id) payable public returns (uint256) {
        Register storage post = idToPost[id];

        if (post.SENT == true) {
            post.idToken = id;
            post.wallet = msg.sender;
            post.SENT = false;
            post.OPEN = true;
            post.READ = false;
            post.FINISHED = false;
            post.lastUpdated = block.timestamp;

            hashToPost[id] = post;

            emit RegisterTrackingOpen(msg.sender, id, block.timestamp);
        }

        return id;
    }

    function read(uint256 id) payable public returns (uint256) {
        Register storage post = idToPost[id];

        if (post.OPEN == true) {
            post.idToken = id;
            post.wallet = msg.sender;
            post.SENT = false;
            post.OPEN = false;
            post.READ = true;
            post.FINISHED = false;
            post.lastUpdated = block.timestamp;
            
            hashToPost[id] = post;

            emit RegisterTrackingRead(msg.sender, id, block.timestamp);
        }

        return id;
    }

    function finished(uint256 id) payable public returns (uint256) {
        Register storage post = idToPost[id];

        if (post.READ == true) {
            post.idToken = id;
            post.wallet = msg.sender;
            post.SENT = false;
            post.OPEN = false;
            post.READ = false;
            post.FINISHED = true;
            post.lastUpdated = block.timestamp;
            
            hashToPost[id] = post;

            emit RegisterTrackingFinished(msg.sender, id, block.timestamp);
        }

        return id;
    }

    function statusNft(uint256 id) public view returns (uint256, address, bool, bool, bool, bool, uint256) {
        return (hashToPost[id].idToken, hashToPost[id].wallet, hashToPost[id].SENT, hashToPost[id].OPEN, hashToPost[id].READ, hashToPost[id].FINISHED, hashToPost[id].lastUpdated);
    }
}