// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";
import { Base64 } from "./libraries/Base64.sol";

contract StoryStarters is ERC721URIStorage, VRFConsumerBase, Ownable {
  using Strings for string;
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  bytes32 internal keyHash;
  uint256 internal fee;
  uint256 public randomResult;
  address public vrfCoordinator;
  address public linkToken;


  string baseSvg = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='firebrick' /><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

  string[] adjectives = ["Enticing", "Captivating", "Magnetic", "Generous", "Courageous", "Athletic", "Compassionate", "Strategic", "Clumsy", "Adventurous", "Cheerful", "Determined", "Creative", "Venerable", "Frenly","Hungry", "Tired", "Cuddly", "Svelte", "Elegant", "Sketchy", "Courageous", "Brilliant"];
  string[] nouns = ["Dog", "Cat", "Coder", "Whale", "Ape", "Astronaut", "Author", "Chef", "Gardener", "Bartender", "Tree", "Admiral", "Bodyguard", "Mapmaker", "Carpenter", "Mouse", "Eggplant"];
  string[] verbs = ["Running", "Climbing", "Singing", "Drawing", "Exploring", "Digging", "Dancing", "Cleaning", "Building", "Laughing", "Praying", "Eating", "Deciphering", "Shopping", "Hiking", "Exploring", "Napping", "Bathing", "Walking"];


  
/**
     network: rinkeby
     vrf coordinator: 0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B
     link token: 0x01BE23585060835E02B77ef475b0Cc51aA1e0709
     key hash: 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311
     fee: 0.1 LINK
     network: mumbai
     vrf coordinator: 0x8C7382F9D8f56b33781fE506E897a4F1e2d17255
     link token address: 0x326C977E6efc84E512bB9C30f76E30c160eD06FB
     key hask: 0x6e75b569a01ef56d18cab6a8e71e6600d6ce853834d4a5748b720d06f878b3a4
     fee: 0.0001 LINK
     constructor(bytes32 _keyhash, address _vrfCoordinator, address _linkToken, uint256 _fee) 
        VRFConsumerBase(
            _vrfCoordinator, // VRF Coordinator
            _linkToken  // LINK Token
        ) 
    {
        keyHash = _keyhash;
        // fee = 0.1 * 10 ** 18; // 0.1 LINK
        fee = _fee;
    }
    // constructor
    constructor(address vrfCoordinator, address link, bytes32 keyHash, uint256 fee)
        public
        VRFConsumerBase(vrfCoordinator, link)
    {
        s_keyHash = keyHash;
        s_fee = fee;
    }
}
     */


  constructor()
      VRFConsumerBase(
          0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B, 
          0x01BE23585060835E02B77ef475b0Cc51aA1e0709)
      ERC721 ("Story Starters", "STST")   

  {
      vrfCoordinator = 0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B;
      linkToken = 0x01BE23585060835E02B77ef475b0Cc51aA1e0709;
      keyHash = 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311;
      fee = 0.1 * 10 ** 18;
  }

  function requestNewStoryStarter()public returns (bytes32 requestId) {
      require(LINK.balanceOf(address(this)) >= fee, "You don't have enough LINK.  Please visit the faucet to fill the contract.");
      requestId = requestRandomness(keyHash, fee);
      //requestToCharacterName[requestId] = name;
      return requestId;
  }

  function fulfillRandomness(bytes32 requestId, uint256 randomNumber)
      internal
      override
  {
      string memory adjective = adjectives[randomNumber % adjectives.length];   //length = 23
      string memory noun = nouns[randomNumber % nouns.length];     //length = 17
      string memory verb= verbs[randomNumber % verbs.length];     //length = 19
      uint256 newItemId = _tokenIds.current();

      string memory combinedWord = string(abi.encodePacked(adjective, noun, verb));

      string memory finalSvg = string(abi.encodePacked(baseSvg, adjective, noun, verb, "</text></svg>"));

      string memory json = Base64.encode(
          bytes(
              string(
                  abi.encodePacked(
                      '{"name": "',
                      combinedWord,
                      '", "description": "A word sketch to ignite your imagination.", "image": "data:image/svg+xml;base64,',
                      Base64.encode(bytes(finalSvg)),
                      '"}'
                  )
              )
          )
      );

      string memory finalTokenUri = string(
          abi.encodePacked("data:application/json;base64,", json)
      );

      console.log("\n--------------------");
      console.log(finalTokenUri);
      console.log("--------------------\n");

      _safeMint(msg.sender, newItemId);
  
      _setTokenURI(newItemId, finalTokenUri);
  
      _tokenIds.increment();
      console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);
  }
}
