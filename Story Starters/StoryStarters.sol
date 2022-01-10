// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import { Base64 } from "./libraries/Base64.sol";

contract StoryStarters is ERC721URIStorage, VRFConsumerBase {
    using Strings for string;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    mapping(bytes32 => address) internal requestIdToSender;
    mapping(bytes32 => uint) internal requestIdToTokenId;
    mapping(uint => uint) internal tokenIdToRandomNumber;

    event requestedRandomSVG(bytes32 indexed requestId, uint indexed tokenId);
    event CreatedRSVGNFT(uint indexed tokenID, string tokenURI);
    event CreatedUnfinishedRandomSVG(uint indexed, uint randomness);

    bytes32 internal keyHash;
    uint256 internal fee;
    uint256 public randomResult;
    address public vrfCoordinator;
    address public linkToken;

    // SVG parameters
    string public svgPartOne;
    string public svgPartTwo;
    string public svgPartThree;
    string public svgPartFour;

    // there are 29 characters    
    string[] characters = [
        "A whale is", 
        "An ape is", 
        "A chef is", 
        "A dancer is", 
        "A super shadowy coder is", 
        "An electrician is", 
        "A ghost is", 
        "A wizard is", 
        "A detective is", 
        "A dog is", 
        "Two paladins are", 
        "Two kittens are", 
        "Two bards are", 
        "Three elves are", 
        "A baker is",
        "A princess is",
        "Three llamas are",
        "An astronaut is",
        "A bartender is",
        "Two librarians are",
        "Four axolotl are",
        "A mantis is",
        "A wolf is",
        "Two bumblebees are",
        "A tired welder is",
        "A famous trucker is",
        "A fruit bat is",
        "Two happy dogs are",
        "A soldier is"
    ];
    
    // there are 23 actions 
    string[] actions = [
        "ordering groceries", 
        "sipping tea", 
        "lifting weights", 
        "practicing yoga", 
        "eating pizza", 
        "carefully exploring", 
        "getting rugged", 
        "playing Stardew Valley", 
        "happily painting", 
        "buying the dip", 
        "climbing a wall", 
        "jumping over a box", 
        "running intervals", 
        "chasing a thief", 
        "cowering behind a bush",
        "avoiding zombies",
        "arguing with a troll",
        "driving a golf cart",
        "solving a crossword puzzle",
        "walking slowly",
        "cooking a feast",
        "building a snowman",
        "debugging a contract"
    ];

    // there are 19 locations 
    string[] locations = [
        "in London.", 
        "on the beach.", 
        "in Iceland.", 
        "inside a tall building.", 
        "at the corner market.", 
        "in a cave.", 
        "in a coffee shop.", 
        "in the backyard.", 
        "on the moon.", 
        "in the metaverse", 
        "in a tattoo parlor.", 
        "in a forest.", 
        "behind the gym.", 
        "at the stadium.", 
        "at Machu Picchu.",
        "above the clouds.",
        "beneath the bridge.",
        "between the palm trees.",
        "on a train."
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
      **/

    constructor()
        ERC721 ("Story Starters", "STST")
        VRFConsumerBase(
            0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B,
            0x01BE23585060835E02B77ef475b0Cc51aA1e0709)
         
    {
        vrfCoordinator = 0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B;
        linkToken = 0x01BE23585060835E02B77ef475b0Cc51aA1e0709;
        keyHash = 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311;
        fee = 0.1 * 10 ** 18;

        // SVG in sections to accomodate text
        
        svgPartOne = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: black; font-family: serif; font-size: 29px; }</style><defs><linearGradient id='grad3' x1='0%' y1='0%' x2='100%' y2='0%'><stop offset='0%' style='stop-color:rgb(255,255,0);stop-opacity:1' /><stop offset='100%' style='stop-color:rgb(255,0,0);stop-opacity:1' /></linearGradient></defs><rect width='100%' height='100%' fill='url(#grad3)' /><text x='50%' y='35%' class='base' dominant-baseline='middle' text-anchor='middle'>";
        svgPartTwo = "</text><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";
        svgPartThree = "</text><text x='50%' y='65%' class='base' dominant-baseline='middle' text-anchor='middle'>";
        svgPartFour= "</text></svg>";

    }

    function igniteImagination() public returns (bytes32 requestId){
    requestId = getRandomNumber();
    requestIdToSender[requestId] = msg.sender;
    uint tokenId = _tokenIds.current();
    requestIdToTokenId[requestId] = tokenId;
    emit requestedRandomSVG(requestId, tokenId);
    _tokenIds.increment();
  }

  // sends request for random number to Chainlink VRF node along with fee
  function getRandomNumber() internal returns (bytes32 requestId) {
    require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
    return requestRandomness(keyHash, fee);
  }

  // callback function called with the returning random value
  function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
    address nftOwner = requestIdToSender[requestId];
    uint tokenId = requestIdToTokenId[requestId];
    _safeMint(nftOwner, tokenId);
    tokenIdToRandomNumber[tokenId] = randomness;
    emit CreatedUnfinishedRandomSVG(tokenId, randomness);
  }

  function tokenURI(uint tokenId) public view override returns(string memory){
    string memory _tokenURI = "Token with that ID does not exist.";
    if (_exists(tokenId)){
      require(tokenIdToRandomNumber[tokenId] > 0, "Need to wait for Chainlink VRF");
      string memory svg = generateSVG(tokenIdToRandomNumber[tokenId]);
      string memory imageURI = svgToImageURI(svg);
      _tokenURI = formatTokenURI(imageURI);
    }
    return _tokenURI;
  }

  function generateSVG(uint _randomNumber) internal view returns(string memory finalSvg){

    uint grabChar = (_randomNumber % 29);
    string memory character = characters[grabChar];

    uint grabAct = (_randomNumber % 23);
    string memory action = actions[grabAct];

    uint grabLoc = (_randomNumber % 19);
    string memory location = locations[grabLoc];

    finalSvg = string(abi.encodePacked(svgPartOne, character, svgPartTwo, action, svgPartThree, location, svgPartFour));
  }

  
  function svgToImageURI(string memory svg) public pure returns(string memory){
    string memory baseURL = "data:image/svg+xml;base64,";
    string memory svgBase64Encoded = Base64.encode(bytes(string(abi.encodePacked(svg))));
    return string(abi.encodePacked(baseURL, svgBase64Encoded));
  }

  function formatTokenURI(string memory imageURI) public pure returns(string memory){
    string memory baseURL = "data:application/json;base64,";
    return string(
      abi.encodePacked(
        baseURL,
        Base64.encode(
          bytes(
            abi.encodePacked(
              '{"name": "A Story Starter", ', 
              '"description": "This is a word sketch to ignite your imagination.", ',
              '"attributes":"", ',
              '"image": "',
              imageURI,
              '"}'
            )
          )
        )
      )
    );
  }
}
