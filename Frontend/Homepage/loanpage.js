// ===============================
// Loan Application JavaScript
// ===============================

// Interest rates according to loan type
const interestRates = {
    "Personal Loan": 11,
    "Home Loan": 8.5,
    "Car Loan": 9,
    "Education Loan": 7.5,
    "Business Loan": 12,
    "Gold Loan": 10
};

// ===============================
// Check Eligibility
// ===============================

function checkEligibility() {

    let income = parseFloat(document.getElementById("income").value);
    let amount = parseFloat(document.getElementById("loanAmount").value);
    let score = parseInt(document.getElementById("creditScore").value);

    let result = document.getElementById("eligibility");

    if(isNaN(income) || isNaN(amount) || isNaN(score)){
        alert("Please fill all required fields.");
        return;
    }

    let maxLoan = income * 10;

    let risk = "";

    if(score >= 750){
        risk = "Low";
    }
    else if(score >= 650){
        risk = "Medium";
    }
    else{
        risk = "High";
    }

    if(amount <= maxLoan && score >= 650){

        result.innerHTML = `
        <span class="success">
        ✅ Eligible for Loan
        </span>
        <br><br>

        Maximum Eligible Amount :
        ₹${maxLoan.toLocaleString()}

        <br>

        Risk Level :
        ${risk}
        `;

    }
    else{

        result.innerHTML = `
        <span class="danger">
        ❌ Not Eligible
        </span>
        <br><br>

        Reason :

        Loan amount exceeds eligibility

        OR

        Credit Score is too low.
        `;

    }

}

// ===============================
// EMI Calculator
// ===============================

function calculateEMI(){

    let amount=parseFloat(
    document.getElementById("loanAmount").value);

    let loanType=document.getElementById("loanType").value;

    let tenure=parseInt(
    document.getElementById("tenure").value);

    let rate=interestRates[loanType];

    let monthlyRate=rate/(12*100);

    let emi=

    (amount*monthlyRate*Math.pow(1+monthlyRate,tenure))

    /

    (Math.pow(1+monthlyRate,tenure)-1);

    let totalPayment=emi*tenure;

    let totalInterest=totalPayment-amount;

    document.getElementById("emi").innerHTML=`

    <span class="success">

    Monthly EMI :
    ₹${emi.toFixed(2)}

    </span>

    <br><br>

    Interest Rate :
    ${rate}%

    <br>

    Total Interest :
    ₹${totalInterest.toFixed(2)}

    <br>

    Total Payment :
    ₹${totalPayment.toFixed(2)}

    `;

}

// ===============================
// Form Validation
// ===============================

document.getElementById("loanForm")

.addEventListener("submit",

function(e){

e.preventDefault();

let customerId=document.getElementById("customerId").value;

let name=document.getElementById("customerName").value;

let amount=document.getElementById("loanAmount").value;

let income=document.getElementById("income").value;

let score=document.getElementById("creditScore").value;

if(customerId==""||
name==""||
amount==""||
income==""||
score==""){

alert("Please fill all mandatory fields.");

return;

}

// Later we'll send this to Java Servlet

alert("Loan Application Submitted Successfully!");

this.reset();

document.getElementById("eligibility").innerHTML="";

document.getElementById("emi").innerHTML="";

});

// ===============================
// Auto Interest Rate Display
// ===============================

document.getElementById("loanType")

.addEventListener("change",function(){

let rate=interestRates[this.value];

console.log("Interest Rate :",rate+"%");

});

// ===============================
// Auto Credit Score Color
// ===============================

document.getElementById("creditScore")

.addEventListener("keyup",function(){

let score=parseInt(this.value);

if(score>=750){

this.style.border="2px solid green";

}
else if(score>=650){

this.style.border="2px solid orange";

}
else{

this.style.border="2px solid red";

}

});

// ===============================
// Reset Form
// ===============================

function resetForm(){

document.getElementById("loanForm").reset();

document.getElementById("eligibility").innerHTML="";

document.getElementById("emi").innerHTML="";

}