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
  address public link;
  bytes32 requestId;


// svg code modified
  string baseSvg = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 27px; }</style><rect width='100%' height='100%' fill='black' /><text x='50%' y='40%' class='base' dominant-baseline='middle' text-anchor='middle'>";

  string[] character = [
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
              "Four bakers are"
            ];

  string[] activity = [
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

  string[] location = [
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


  constructor(address vrfCoordinator, address link, bytes32 keyHash, uint256 fee)
      VRFConsumerBase(
          0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B, 
          0x01BE23585060835E02B77ef475b0Cc51aA1e0709)
      ERC721 ("Story Starters", "STST")   

  {
      vrfCoordinator = 0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B;
      link = 0x01BE23585060835E02B77ef475b0Cc51aA1e0709;
      keyHash = 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311;
      fee = 0.1 * 10 ** 18;
    }
  
  function getRandomNumber() public returns (bytes32 requestId) {
      require(LINK.balanceOf(address(this)) >= fee, "You need more LINK.  Please visit the faucet.");
        return requestRandomness(keyHash, fee);
    }

  function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
    randomResult = randomness % 2021;
  }


  // there are 15 different characters  
  function pickRandomCharacter(uint256 tokenId) public view returns (string memory) {
    uint256 rand = random(string(abi.encodePacked("character", Strings.toString(tokenId))));
    rand = randomResult % character.length;
    return character[rand];
  }

  // there are 17 different activities
  function pickRandomActivity(uint256 tokenId) public view returns (string memory) {
    uint256 rand = random(string(abi.encodePacked("activity", Strings.toString(tokenId))));
    rand = randomResult % activity.length;
    return activity[rand];
  }
  // there are 19 different locations
  function pickRandomLocation(uint256 tokenId) public view returns (string memory) {
    uint256 rand = random(string(abi.encodePacked("location", Strings.toString(tokenId))));
    rand = randomResult % location.length;
    return location[rand];
  }

  function random(string memory input) internal pure returns (uint256) {
      return uint256(keccak256(abi.encodePacked(input)));
  }

  function makeStoryStarter() public {
    uint256 newItemId = _tokenIds.current();

    // combine the three phrases
        // We go and randomly grab one word from each of the three arrays.
    string memory character = pickRandomCharacter(newItemId);
    string memory activity = pickRandomActivity(newItemId);
    string memory location = pickRandomLocation(newItemId);
    string memory combinedPhrase = string(abi.encodePacked(character, activity, location));

    string memory finalSvg = string(abi.encodePacked(baseSvg, character, "</text><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>", activity, "</text><text x='50%' y='60%' class='base' dominant-baseline='middle' text-anchor='middle'>", location, "</text></svg>"));
    
    // Get all the JSON metadata in place and base64 encode it.
    string memory json = Base64.encode(
        bytes(
          string(
             abi.encodePacked(
                  '{"name": "',
                  combinedPhrase,
                  '", "description": "A word sketch to ignite your imagination.", "image": "data:image/svg+xml;base64,',
                  // add data:image/svg+xml;base64 and then append base64 & encode our svg
                  Base64.encode(bytes(finalSvg)),
                  '"}'
                )
              )
           )
      );

    // prepend data:application/json;base64 to our data.
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