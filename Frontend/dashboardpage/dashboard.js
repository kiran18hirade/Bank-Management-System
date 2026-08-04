// ==============================
// Dashboard JavaScript
// Loan Approval & Credit Management
// ==============================

// Get Login Details
const role = localStorage.getItem("role") || "customer";
const name = localStorage.getItem("name") || "User";

// Welcome Message
document.getElementById("welcomeUser").innerHTML = "Welcome, " + name;

// -------------------------------
// Menu
// -------------------------------

const menu = document.getElementById("menu");

if(role === "customer"){

menu.innerHTML = `

<li onclick="goDashboard()">
<i class="fa-solid fa-house"></i>
Dashboard
</li>

<li onclick="applyLoan()">
<i class="fa-solid fa-file-circle-plus"></i>
Apply Loan
</li>

<li>
<i class="fa-solid fa-money-bill"></i>
My Loans
</li>

<li>
<i class="fa-solid fa-credit-card"></i>
EMI Schedule
</li>

<li>
<i class="fa-solid fa-chart-line"></i>
Credit Score
</li>

<li>
<i class="fa-solid fa-user"></i>
Profile
</li>

<li onclick="logout()">
<i class="fa-solid fa-right-from-bracket"></i>
Logout
</li>

`;

}
else{

menu.innerHTML = `

<li onclick="goDashboard()">
<i class="fa-solid fa-house"></i>
Dashboard
</li>

<li>
<i class="fa-solid fa-users"></i>
Customers
</li>

<li onclick="applyLoan()">
<i class="fa-solid fa-file-circle-plus"></i>
Loan Applications
</li>

<li>
<i class="fa-solid fa-check"></i>
Loan Approval
</li>

<li>
<i class="fa-solid fa-chart-line"></i>
Credit Management
</li>

<li>
<i class="fa-solid fa-chart-column"></i>
Reports
</li>

<li>
<i class="fa-solid fa-clock"></i>
Audit Logs
</li>

<li onclick="logout()">
<i class="fa-solid fa-right-from-bracket"></i>
Logout
</li>

`;

}

// -------------------------------
// Cards
// -------------------------------

const cards=document.getElementById("cards");

if(role==="customer"){

cards.innerHTML=`

<div class="card">
<h3>Credit Score</h3>
<h1>785</h1>
</div>

<div class="card">
<h3>Loan Status</h3>
<h1>Approved</h1>
</div>

<div class="card">
<h3>Outstanding Loan</h3>
<h1>₹2,50,000</h1>
</div>

<div class="card">
<h3>Next EMI</h3>
<h1>15 Aug</h1>
</div>

`;

}
else{

cards.innerHTML=`

<div class="card">
<h3>Total Customers</h3>
<h1>1250</h1>
</div>

<div class="card">
<h3>Pending Loans</h3>
<h1>18</h1>
</div>

<div class="card">
<h3>Approved Loans</h3>
<h1>324</h1>
</div>

<div class="card">
<h3>Rejected Loans</h3>
<h1>42</h1>
</div>

`;

}

// -------------------------------
// Tables
// -------------------------------

const tableHead=document.getElementById("tableHead");
const tableBody=document.getElementById("tableBody");
const tableTitle=document.getElementById("tableTitle");

if(role==="customer"){

tableTitle.innerHTML="My Loans";

tableHead.innerHTML=`

<tr>

<th>Loan ID</th>

<th>Loan Type</th>

<th>Amount</th>

<th>Status</th>

<th>Next EMI</th>

</tr>

`;

tableBody.innerHTML=`

<tr>

<td>L101</td>

<td>Home Loan</td>

<td>₹15,00,000</td>

<td>Approved</td>

<td>₹18,250</td>

</tr>

<tr>

<td>L102</td>

<td>Education Loan</td>

<td>₹4,50,000</td>

<td>Pending</td>

<td>-</td>

</tr>

`;

}
else{

tableTitle.innerHTML="Pending Loan Applications";

tableHead.innerHTML=`

<tr>

<th>Loan ID</th>

<th>Customer</th>

<th>Amount</th>

<th>Credit Score</th>

<th>Status</th>

<th>Action</th>

</tr>

`;

tableBody.innerHTML=`

<tr>

<td>L101</td>

<td>Rahul Sharma</td>

<td>₹5,00,000</td>

<td>785</td>

<td>Pending</td>

<td><button>View</button></td>

</tr>

<tr>

<td>L102</td>

<td>Priya Patil</td>

<td>₹8,50,000</td>

<td>730</td>

<td>Pending</td>

<td><button>View</button></td>

</tr>

`;

}

// -------------------------------
// Charts
// -------------------------------

if(role==="customer"){

document.getElementById("chart1Title").innerHTML="Loan Status";
document.getElementById("chart2Title").innerHTML="EMI Progress";

new Chart(document.getElementById("loanChart"),{

type:"doughnut",

data:{
labels:["Paid","Remaining"],
datasets:[{
data:[35,65]
}]
}

});

new Chart(document.getElementById("applicationChart"),{

type:"bar",

data:{
labels:["Jan","Feb","Mar","Apr","May"],
datasets:[{
label:"EMI Paid",
data:[2,2,2,2,2]
}]
}

});

}
else{

document.getElementById("chart1Title").innerHTML="Loan Status";
document.getElementById("chart2Title").innerHTML="Monthly Applications";

new Chart(document.getElementById("loanChart"),{

type:"pie",

data:{
labels:["Approved","Pending","Rejected"],
datasets:[{
data:[324,18,42]
}]
}

});

new Chart(document.getElementById("applicationChart"),{

type:"bar",

data:{
labels:["Jan","Feb","Mar","Apr","May","Jun"],
datasets:[{
label:"Applications",
data:[15,20,25,18,30,27]
}]
}

});

}

// -------------------------------
// Search
// -------------------------------

document.getElementById("searchBox").addEventListener("keyup",function(){

let value=this.value.toLowerCase();

let rows=document.querySelectorAll("#tableBody tr");

rows.forEach(row=>{

if(row.innerText.toLowerCase().includes(value))
row.style.display="";
else
row.style.display="none";

});

});

// -------------------------------
// Navigation
// -------------------------------

function applyLoan(){

window.location.href="../Loanpage/loanpage.html";

}

function goDashboard(){

window.location.href="dashboard.html";

}

function logout(){

localStorage.clear();

window.location.href="index.html";

}