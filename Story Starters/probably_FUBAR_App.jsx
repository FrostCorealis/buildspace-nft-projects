import { ethers } from "ethers";
import React, { useEffect, useState } from "react";
import './styles/App.css';
import StoryStarters from './utils/StoryStarters.json';
import twitterLogo from './assets/twitter-logo.svg';

const BUILDSPACE_LINK = 'https://buildspace.so';
const TWITTER_HANDLE = 'FrostCorealis';
const TWITTER_LINK = `https://twitter.com/${TWITTER_HANDLE}`;
const RARIBLE_LINK = 'https://rinkeby.rarible.com/collection/0x74b2f1e6fdd7fd14108dd0f5823dfbc2fff268be';
const OPENSEA_LINK = 'https://testnets.opensea.io/collection/story-starters-ue9lxn3eim';
const CONTRACT_ADDRESS = "0x7A592D2b0ca122798c6d4fd09707DA192dd6bcB9";

const App = () => {
  const [currentAccount, setCurrentAccount] = useState("");
    
  const checkIfWalletIsConnected = async () => {
    const { ethereum } = window;

    if (!ethereum) {
      console.log("Make sure you have metamask!");
      return;
    } else {
      console.log("We have the ethereum object", ethereum);
    }

    const accounts = await ethereum.request({ method: "eth_accounts" });

    if (accounts.length !== 0) {
      const account = accounts[0];
      console.log("Found an authorized account:", account);
      setCurrentAccount(account)
      setupEventListener()
   } else {
     console.log("No authorized account found")
   }
};

  /*
  * Implement your connectWallet method here
  */
const connectWallet = async () => {
  try {
    const { ethereum } = window;

    if (!ethereum) {
      alert("Get MetaMask!");
      return;
    }
    /*
     * Fancy method to request access to account.
     */
    const accounts = await ethereum.request({ method: "eth_requestAccounts" });

    console.log("Connected", accounts[0]);
    setCurrentAccount(accounts[0]);
    setupEventListener() 
  } catch (error) {
    console.log(error)
  }
};

  // Setup our listener.
  const setupEventListener = async () => {
    // Most of this looks the same as our function askContractToMintNft
    try {
      const { ethereum } = window;

      if (ethereum) {
        // Same stuff again
        const provider = new ethers.providers.Web3Provider(ethereum);
        const signer = provider.getSigner();
        const connectedContract = new ethers.Contract(CONTRACT_ADDRESS, StoryStarters.abi, signer);


        console.log("Setup event listener!")

      } else {
        console.log("Ethereum object doesn't exist!");
      }
    } catch (error) {
      console.log(error)
    }
  }

const askContractTorequestNewStoryStarter = async () => {
  
  try {
    const { ethereum } = window;

    if (ethereum) {
      const provider = new ethers.providers.Web3Provider(ethereum);
      const signer = provider.getSigner();
      const connectedContract = new ethers.Contract(CONTRACT_ADDRESS, StoryStarters.abi, signer);

      console.log("Paying for gas...")
      let nftTxn = await connectedContract.requestNewStoryStarter();

      console.log("Minting...please wait.")
      await nftTxn.wait();
        
      console.log(`Minted, see transaction: https://rinkeby.etherscan.io/tx/${nftTxn.hash}`);

    } else {
      console.log("Ethereum object doesn't exist!");
    }
  } catch (error) {
    console.log(error)
 }
};  

// Render Methods
  const renderNotConnectedContainer = () => (
    <button onClick={connectWallet} className="cta-button connect-wallet-button">
      Connect to Wallet
    </button>
  );

  useEffect(() => {
    checkIfWalletIsConnected();
  }, []);
//HERE

  /*
  * Added a conditional render! We don't want to show Connect to Wallet if we're already conencted :).
  */
  return (
    <div className="App">
      <div className="container">
        <div className="header-container">
          <p className="header gradient-text">Story Starters</p>
          <p className="sub-text">
            Word Sketches to ignite your imagination.
          </p>
          {currentAccount === "" ? (
            renderNotConnectedContainer()
          ) : (
            <button onClick={askContractTorequestNewStoryStarter} className="cta-button connect-wallet-button">
              Mint NFT
            </button>
          )}
          <p className="spacer-text">{' '}</p>

          <button className="opensea-button"><a 
            href={RARIBLE_LINK}
            target="_blank"
            rel="noreferrer">
              💛 {' '} View Collection on Rarible
            </a></button>
            
            <button onClick={OPENSEA_LINK} className="opensea-button"><a 
            href={OPENSEA_LINK}
            target="_blank"
            rel="noreferrer">
              🌊 {' '} View Collection on OpenSea
            </a></button>
        </div>

        <div className="footer-container">
          <p className="footer-text"> built on <a
            className="footer-text"
            href={BUILDSPACE_LINK}
            target="_blank"
            rel="noreferrer"
          >{' '}buildspace 🦄</a></p>
          <p className="footer-text">by    
          <a
            className="footer-text"
            href={TWITTER_LINK}
            target="_blank"
            rel="noreferrer"
          >{' '}@FrostCorealis</a>
           
          </p>
        </div>
      </div>
    </div>
  );
};

export default App;
