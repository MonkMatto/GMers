let networkId = null;
const baseId = 8453; // Base network ID
const sepoliaId = 11155111; // Sepolia network ID

const web3 = new Web3(
  "https://base-mainnet.g.alchemy.com/v2/nJjDju3_gVrkM3kbohw2LZld-hf0093B"
); // Production API link locked to domain and contracts. :)

const MAIN_ADDRESS = "0x05aabe669560f807bae71139ab5df3d439645025";
const mainContractAlchemy = new web3.eth.Contract(MAIN_ABI, MAIN_ADDRESS);
let web3User = null; // For MetaMask or any Ethereum-compatible wallet
let mainContractUser = null; // For MetaMask or any Ethereum-compatible wallet

/*****************************************/
/* Detect the MetaMask Ethereum provider */
/*****************************************/
async function getProvider(){
    const provider = await detectEthereumProvider();
    if (provider) {
        startApp(provider);
    } else {
        console.log('Please install MetaMask!');
    }
}

getProvider();


async function checkNetwork() {
    networkId = await web3User.eth.getChainId(); // Get the current network ID
    const networkMessageElement = document.getElementById('network-message');
    
    if (networkId !== baseId) {
        networkMessageElement.innerHTML = '⚠️ Please connect to the Base network.';
        console.error('Connected to the wrong network, ID:', networkId);
    } else {
        networkMessageElement.innerHTML =
          "💙💙💙";
    }
}

function startApp(provider) {
    if (provider !== window.ethereum) {
        console.error('Do you have multiple wallets installed?');
    }
    web3User = new Web3(provider); // Initialize user's web3
    mainContractUser = new web3User.eth.Contract(MAIN_ABI, MAIN_ADDRESS);

    // Attach event handlers
    ethereum.on('chainChanged', (_chainId) => {
        window.location.reload();
        checkNetwork(); // Re-check network after chain change
    });
    ethereum.on('accountsChanged', handleAccountsChanged);

    // Check for existing accounts and network
    ethereum
        .request({ method: 'eth_accounts' })
        .then(handleAccountsChanged)
        .catch(handleError);
    checkNetwork(); // Check network at startup
}

function handleChainChanged(_chainId) {
    checkNetwork(); // Check network when chain changes
    window.location.reload();
}

// Existing code for handleAccountsChanged, handleError, connectWallet remains unchanged


let currentAccount = null;

function handleAccountsChanged(accounts) {
    if (accounts.length === 0) {
        console.log('Please connect to MetaMask.');
        document.getElementById("connect-button-text").innerHTML =
          "Connect MetaMask";
    } else if (accounts[0] !== currentAccount) {
        currentAccount = accounts[0];
        console.log("Account connected:", currentAccount);
        document.getElementById(
          "connect-button-text"
        ).innerHTML = `${currentAccount.slice(0,6)}... Connected`;
    }
}

function handleError(error) {
    console.error(error);
}

function connectWallet() {
    ethereum
        .request({ method: 'eth_requestAccounts' })
        .then(handleAccountsChanged)
        .catch(handleError);
}