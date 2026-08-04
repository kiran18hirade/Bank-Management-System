// ===============================
// Login JavaScript
// Loan Approval & Credit Management
// ===============================

// Default role
let currentRole = "customer";

// -------------------------------
// Switch Login Role
// -------------------------------
function switchUser(role) {

    currentRole = role;

    const customerBtn = document.getElementById("customerBtn");
    const employeeBtn = document.getElementById("employeeBtn");

    if (role === "customer") {
        customerBtn.classList.add("active");
        employeeBtn.classList.remove("active");
    } else {
        employeeBtn.classList.add("active");
        customerBtn.classList.remove("active");
    }

}

// -------------------------------
// Show / Hide Password
// -------------------------------
function togglePassword() {

    const password = document.getElementById("password");
    const eye = document.getElementById("togglePassword");

    if (password.type === "password") {

        password.type = "text";

        eye.classList.remove("fa-eye");
        eye.classList.add("fa-eye-slash");

    } else {

        password.type = "password";

        eye.classList.remove("fa-eye-slash");
        eye.classList.add("fa-eye");

    }

}

// -------------------------------
// Login Validation
// -------------------------------

document.getElementById("loginForm")
.addEventListener("submit", function(e){

    e.preventDefault();

    let email = document.getElementById("email").value.trim();
    let password = document.getElementById("password").value.trim();

    if(email === "" || password === ""){
        alert("Please enter Email and Password");
        return;
    }

    if(!validateEmail(email)){
        alert("Invalid Email Address");
        return;
    }

    // ==========================
    // TEMP LOGIN
    // Replace with Java Servlet
    // ==========================
  
    if(currentRole === "customer"){

        if(email === "customer@gmail.com" && password === "1234"){

       alert("Customer Login Successful");

        localStorage.setItem("role","customer");
        localStorage.setItem("name","Kiran Hirade");
        localStorage.setItem("email",email);

        window.location.href="../dashboardpage/dashboard.html";

}
        else{

            alert("Invalid Customer Credentials");

        }

    }

    else{

        if(email === "employee@gmail.com" && password === "admin123"){

    alert("Employee Login Successful");

    localStorage.setItem("role","employee");
    localStorage.setItem("name","Loan Officer");
    localStorage.setItem("email",email);

    window.location.href="../dashboardpage/dashboard.html";

}
        else{

            alert("Invalid Employee Credentials");

        }

    }

});

// -------------------------------
// Email Validation
// -------------------------------

function validateEmail(email){

    let pattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

    return pattern.test(email);

}

// -------------------------------
// Auto Login
// -------------------------------
window.onload = function(){

    const role = localStorage.getItem("role");
    const name = localStorage.getItem("name");

    if(role){

        console.log("Role :", role);
        console.log("User :", name);

    }

};

// -------------------------------
// Logout
// -------------------------------

function logout(){

    localStorage.clear();

    window.location.href="index.html";

}