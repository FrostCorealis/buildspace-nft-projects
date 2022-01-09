import { ethers } from "ethers";
import React, { useEffect, useState } from "react";
import './styles/App.css';
import StoryStarters from './utils/StoryStarters.json';

const BUILDSPACE_LINK = 'https://buildspace.so';
const CHAINLINK_LINK = 'https://docs.chain.link';
const REPLIT_LINK = 'https://replit.com'
const TWITTER_HANDLE = 'FrostCorealis';
const TWITTER_LINK = `https://twitter.com/${TWITTER_HANDLE}`;
const RARIBLE_LINK = 'https://rinkeby.rarible.com/collection/0x5f984f4b44a545861733be21bb1ea5058ad495f0/items';
const OPENSEA_LINK = 'https://testnets.opensea.io/collection/story-starters-ujvsqtcyqv';
const CONTRACT_ADDRESS = "0x5F984F4B44A545861733be21bB1EA5058aD495F0";

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

//connectWallet method 
const connectWallet = async () => {
  try {
    const { ethereum } = window;

    if (!ethereum) {
      alert("Get MetaMask!");
      return;
    }
    //request access to account.
    const accounts = await ethereum.request({ method: "eth_requestAccounts" });

    console.log("Connected", accounts[0]);
    setCurrentAccount(accounts[0]);
    setupEventListener() 
  } catch (error) {
    console.log(error)
  }
};

  //listener
  const setupEventListener = async () => {
    try {
      const { ethereum } = window;

      if (ethereum) {
        const provider = new ethers.providers.Web3Provider(ethereum);
        const signer = provider.getSigner();
        const connectedContract = new ethers.Contract(CONTRACT_ADDRESS, StoryStarters.abi, signer);

        console.log("Event listener up!")

      } else {
        console.log("Ethereum object doesn't exist!");
      }
    } catch (error) {
      console.log(error)
    }
  }

const askContractToMintNft = async () => {
  
  try {
    const { ethereum } = window;

    if (ethereum) {
      const provider = new ethers.providers.Web3Provider(ethereum);
      const signer = provider.getSigner();
      const connectedContract = new ethers.Contract(CONTRACT_ADDRESS, StoryStarters.abi, signer);

      console.log("Paying for gas...")
      let nftTxn = await connectedContract.igniteImagination();

      console.log("Contacting the VRF before preparing your Story Starter...")
      await nftTxn.wait();
        
      console.log(`Your Story Starter is ready for you! See transaction: https://rinkeby.etherscan.io/tx/${nftTxn.hash}`);

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
            <button onClick={askContractToMintNft} className="cta-button connect-wallet-button">
              Mint a Story Starter
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
          <p className="footer-text"> built on{' '}<a
            className="footer-text"
            href={BUILDSPACE_LINK}
            target="_blank"
            rel="noreferrer"
          >{' '}buildspace 🦄</a>{' '}by    
          <a
            className="footer-text"
            href={TWITTER_LINK}
            target="_blank"
            rel="noreferrer"
          >{' '}Frost Corealis</a>
           <p className="footer-text"> with special thanks to{' '}<a
            className="footer-text"
            href={CHAINLINK_LINK}
            target="_blank"
            rel="noreferrer"
          >{' '}chainlink</a>{' '}and{' '}<a
            className="footer-text"
            href={REPLIT_LINK}
            target="_blank"
            rel="noreferrer"
          >{' '}replit</a></p>
           
          </p>
        </div>
      </div>
    </div>
  );
};

export default App;
