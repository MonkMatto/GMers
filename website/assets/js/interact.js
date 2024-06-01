var amountToMint, fee, addy, error;

// document.addEventListener("DOMContentLoaded", function(event) {
//     updateTotalSupply();
// });

document.addEventListener("DOMContentLoaded", function (event) {
  updateTotalSupply();
  var selectElement = document.getElementById("amount-to-mint");
  var mintCostSpan = document.getElementById("mint-cost");

  selectElement.addEventListener("change", function () {
    var numberOfGMers = parseInt(this.value);
    var costPerGMer = 0.0001;
    var totalCost = numberOfGMers * costPerGMer;
    mintCostSpan.textContent = `${totalCost.toFixed(4)}`;
  });
});


async function updateTotalSupply() {
    try {
        const minted = await mainContractAlchemy.methods
          .totalSupply()
          .call();
        const supplyElements = document.querySelectorAll(".total-supply");
        supplyElements.forEach((element) => {
          element.innerHTML = minted;
        });
        // document.getElementById(`total-supply`).innerHTML = minted;
    } catch (err) {
        console.error("Error fetching totalSupply:", err);
    }  
}

async function mint() {
  if (!web3User) {
    console.error(
      "User's Web3 not initialized. Please connect a wallet."
    );
    return;
  }
  if (networkId !== baseId && networkId !== sepoliaId) {
    alert("Please connect to the Base network.");
    return;
  }
  console.log("Connected to network: ", networkId);
  error = false;
  amountToMint = document.getElementById("amount-to-mint").value;
  fee = amountToMint * 100000000000000;
  console.log(fee);
  console.log(currentAccount + " is attempting to mint " + amountToMint + " tokens for a total of " + fee + " wei.");
  try {
    await mainContractUser.methods.mint(currentAccount, amountToMint).send(
      {
        from: currentAccount,
        value: fee
      },
      function (err, res) {
        if (err) {
          console.log(err);
          return;
        }
      }
    );
  } catch (errorMessage) {
    error = true;
  }
  if (error) {
    alert("There was an error. Please try again.");
  }
  updateTotalSupply();
}
