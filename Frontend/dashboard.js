// ========================================
// Loan Approval & Credit Management System
// dashboard.js
// ========================================

// Current Logged User
let currentUser = {
    id: 1,
    name: "Kiran Hirade",
    role: "Employee"
};

// Dashboard Data (Temporary)
// Replace these with API calls later
const dashboardData = {

    customers: 1250,

    pendingLoans: 18,

    approvedLoans: 324,

    rejectedLoans: 42,

    outstandingAmount: 24500000,

    emiCollection: 5200000

};

// Loan Applications

const loanApplications = [

{
id:"L1001",
customer:"Rahul Sharma",
amount:500000,
credit:790,
status:"Pending"
},

{
id:"L1002",
customer:"Priya Patil",
amount:350000,
credit:760,
status:"Approved"
},

{
id:"L1003",
customer:"Amit Kumar",
amount:800000,
credit:640,
status:"Rejected"
},

{
id:"L1004",
customer:"Sneha Joshi",
amount:250000,
credit:715,
status:"Pending"
}

];


// ===================================
// Initial Load
// ===================================

window.onload=function(){

loadDashboard();

loadCharts();

notificationCheck();

}


// ===================================
// Dashboard Cards
// ===================================

function loadDashboard(){

document.querySelectorAll(".card h1")[0].innerHTML=
dashboardData.customers;

document.querySelectorAll(".card h1")[1].innerHTML=
dashboardData.pendingLoans;

document.querySelectorAll(".card h1")[2].innerHTML=
dashboardData.approvedLoans;

document.querySelectorAll(".card h1")[3].innerHTML=
dashboardData.rejectedLoans;

}



// ===================================
// Search Customer
// ===================================

const searchBox=document.querySelector(".search input");

if(searchBox){

searchBox.addEventListener("keyup",function(){

let value=this.value.toLowerCase();

let rows=document.querySelectorAll("tbody tr");

rows.forEach(row=>{

let name=row.cells[1].innerHTML.toLowerCase();

if(name.includes(value)){

row.style.display="";

}
else{

row.style.display="none";

}

});

});

}


// ===================================
// View Loan Details
// ===================================

document.querySelectorAll(".view-btn").forEach(button=>{

button.onclick=function(){

let row=this.parentElement.parentElement;

let loanId=row.cells[0].innerHTML;

alert("Open Loan Details : "+loanId);

// Later

// location.href="loan-details.html?id="+loanId;

}

});


// ===================================
// Notification
// ===================================

function notificationCheck(){

let pending=dashboardData.pendingLoans;

if(pending>0){

console.log(
"You have "+pending+" pending applications."
);

}

}


// ===================================
// Logout
// ===================================

function logout(){

let ans=confirm("Logout ?");

if(ans){

window.location="index.html";

}

}


// ===================================
// Charts
// ===================================

function loadCharts(){

// Loan Status

const ctx=document.getElementById("loanChart");

if(ctx){

new Chart(ctx,{

type:"pie",

data:{

labels:[
"Approved",
"Rejected",
"Pending"
],

datasets:[{

data:[

dashboardData.approvedLoans,

dashboardData.rejectedLoans,

dashboardData.pendingLoans

],

backgroundColor:[

"#2E7D32",

"#C62828",

"#F9A825"

]

}]

}

});

}


// Monthly Chart

const ctx2=document.getElementById("applicationChart");

if(ctx2){

new Chart(ctx2,{

type:"bar",

data:{

labels:[

"Jan",

"Feb",

"Mar",

"Apr",

"May",

"Jun"

],

datasets:[{

label:"Applications",

data:[

15,

18,

25,

20,

32,

28

],

backgroundColor:"#1E88E5"

}]

}

});

}

}