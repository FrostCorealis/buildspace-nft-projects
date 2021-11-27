import { ethers } from "ethers";
import React, { useEffect, useState } from "react";
import './styles/App.css';
import myEpicNft from './utils/MyEpicNFT.json';
import twitterLogo from './assets/twitter-logo.svg';

const BUILDSPACE_LINK = 'https://buildspace.so';
const TWITTER_HANDLE = 'FrostCorealis';
const TWITTER_LINK = `https://twitter.com/${TWITTER_HANDLE}`;
const RARIBLE_LINK = 'https://rinkeby.rarible.com/collection/0x72ce4b2aeb4bc01859e95060432c86c5cdf8a60c';
const OPENSEA_LINK = 'https://testnets.opensea.io/collection/new-frens-h8wtiq0mah';
const TOTAL_MINT_COUNT = 50;
const CONTRACT_ADDRESS = "0x72Ce4B2Aeb4BC01859E95060432c86C5cdf8A60c";

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
        const connectedContract = new ethers.Contract(CONTRACT_ADDRESS, myEpicNft.abi, signer);


        console.log("Setup event listener!")

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
      const connectedContract = new ethers.Contract(CONTRACT_ADDRESS, myEpicNft.abi, signer);

      console.log("Taking care of gas fees...")
      let nftTxn = await connectedContract.makeAnEpicNFT();

      console.log("Locating your New Fren...please wait.")
      await nftTxn.wait();
        
      console.log(`Your New Fren is here!  See transaction: https://rinkeby.etherscan.io/tx/${nftTxn.hash}`);

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

  /*
   * Added a conditional render! We don't want to show Connect to Wallet if we're already conencted :).
   */
  return (
    <div className="App">
      <div className="container">
        <div className="header-container">
          <p className="header gradient-text">New Frens</p>
          <p className="sub-text">
            Meet a new fren who will inspire your imagination.
          </p>
          {currentAccount === "" ? (
            renderNotConnectedContainer()
          ) : (
            <button onClick={askContractToMintNft} className="cta-button connect-wallet-button">
              Mint New Fren
            </button>
          )}
          <p className="spacer-text">{' '}</p>

          <button className="opensea-button"><a 
            href={RARIBLE_LINK}
            target="_blank"
            rel="noreferrer">
              💛 {' '} View Collection on Rarible
            </a></button>
            
            <button className="opensea-button"><a 
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
