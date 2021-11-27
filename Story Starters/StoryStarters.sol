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

  string baseSvg = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='firebrick'><style>.base { fill: white; font-family: serif; font-size: 27px; }</style><rect width='100%' height='100%' fill='black' /><text x='50%' y='40%' class='base' dominant-baseline='middle' text-anchor='middle'>";

  string[] characters = [
              "A whale is", 
              "An ape is", 
              "A chef is", 
              "A dancer is", 
              "An artist is", 
              "An electrician is", 
              "A ghost is", 
              "A wizard is", 
              "A detective is", 
              "A dog is", 
              "Two paladins are", 
              "Two kittens are", 
              "Two bards are", 
              "Three elves are", 
              "Four bakers are",
              "Five spicers are",
              "A coder is",
              "A crocodile is",
              "Two dragons are",
              "A knight is",
              "A princess is",
              "Five robots are",
              "An astronaut is"
            ];

  string[] activities = [
              " ordering groceries", 
              " sipping tea", 
              " hiking", 
              " practicing yoga", 
              " eating pizza", 
              " exploring", 
              " getting rugged", 
              " playing Stardew Valley", 
              " painting", 
              " buying the dip", 
              " climbing a wall", 
              " jumping over a box", 
              " running", 
              " chasing a theif", 
              " cowering behind a bush",
              " lifing weights",
              " singing"
            ];

  string[] locations = [
             " in London.", 
             " at the beach.", 
             " in Iceland.", 
             " inside a tall building.", 
             " at the corner market.", 
             " in a cave.", 
             " in a coffee shop.", 
             " in the backyard.", 
             " on the moon.", 
             " in the metaverse", 
             " in a tattoo parlor.", 
             " in the forest.", 
             " behind the gym.", 
             " at the stadium.", 
             " at Machu Picchu.",
             " under the bridge.",
             " beside the cliff.",
             " beneath the city.",
             " above the river."
          ];

  struct StoryStarter {
        string character;
        string activity;
        string location;
    }

  mapping(bytes32 => address) requestToSender;  


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

  function requestNewStoryStarter()public returns (bytes32) {
      require(
          LINK.balanceOf(address(this)) >= fee,
          "You don't have enough LINK.  Please visit the faucet to fill the contract."
      );
      bytes32 requestId = requestRandomness(keyHash, fee);
      //requestToCharacterName[requestId] = name;
      requestToSender[requestId] = msg.sender;
      return requestId;
  }

  function fulfillRandomness(bytes32 requestId, uint256 randomNumber)
      internal
      override
  {
      string memory character = characters[randomNumber % characters.length];   //length = 23
      string memory activity = activities[randomNumber % activities.length];     //length = 17
      string memory location = locations[randomNumber % locations.length];     //length = 19
      uint256 newItemId = _tokenIds.current();


      string memory name = string(abi.encodePacked(character, activity, location));
      string memory finalSvg = string(abi.encodePacked(baseSvg, character, "</text><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>", activity, "</text><text x='50%' y='60%' class='base' dominant-baseline='middle' text-anchor='middle'>", location, "</text></svg>"));
    
      string memory json = Base64.encode(
          bytes(
              string(
                  abi.encodePacked(
                      '{"name": "',
                      name,
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
