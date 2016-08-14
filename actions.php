<?php 

    $servername = "localhost";
    $dbname = "xxx";
    $username = "xxx";
    $password = "xxx";

    // Create & check connection
    $conn = new mysqli($servername, $username, $password);
    if ($conn->connect_error) {
        die("Connection failed: " . $conn->connect_error);
    } 
    else {
        mysqli_select_db($conn, $dbname);
    }



    if (isset($_POST['addPokemon'])) {
        writeToLogs("PokemonAdded.txt", "\n\n\n Adding New Pokemon... [" . date("Y-m-d h:i:sa", time()) . "]");
        writeToLogs("PokemonAdded.txt", "\n ----------------------------------------");


        $name = $conn->real_escape_string($_POST['name']); 
        $username = $conn->real_escape_string($_POST['username']); 
        $latitude = $conn->real_escape_string($_POST['latitude']); 
        $longitude = $conn->real_escape_string($_POST['longitude']); 


        $sql = "INSERT INTO pokemon (name, username, latitude, longitude) VALUES('" . $name . "', '" . $username . "', '" . $latitude . "', '" . $longitude . "')";
        $result = mysqli_query($conn, $sql);
        if(!$result) {
            writeToLogs("PokemonAdded.txt", "\n " . $name . " could not be added.");
            echo("failure");
        }
        else {
            writeToLogs("PokemonAdded.txt", "\n " . $name. " added successfully.");
            echo("success");
        }
    }
    else if (isset($_POST['getPokemon'])) {
        writeToLogs("PokemonRetrieved.txt", "\n\n\n Getting Pokemon... [" . date("Y-m-d h:i:sa", time()) . "]");
        writeToLogs("PokemonRetrieved.txt", "\n ----------------------------------------");


        $sql = "SELECT * FROM pokemon";
        $result = mysqli_query($conn, $sql);
        if(mysqli_num_rows($result) > 0) {
            writeToLogs("PokemonRetrieved.txt", "\n Successfully retrieved all Pokemon.");

            $allPokemon = array();
            while($row = mysqli_fetch_array($result)) {
                $pokemon = array();
                $pokemon["name"] = $row["name"];
                $pokemon["latitude"] = $row["latitude"];
                $pokemon["longitude"] = $row["longitude"];
                array_push($allPokemon, $pokemon);
            }

            echo json_encode($allPokemon);
        }
        else {
            writeToLogs("PokemonRetrieved.txt", "\n Could not retrieve all Pokemon.");
            echo "Error: " . mysqli_error($conn);
        }
    }
    else if (isset($_POST['checkUser'])) {
        writeToLogs("UsersAdded.txt", "\n\n\n Checking User... [" . date("Y-m-d h:i:sa", time()) . "]");
        writeToLogs("UsersAdded.txt", "\n ----------------------------------------");


        $username = $conn->real_escape_string($_POST['username']); 
        $email = $conn->real_escape_string($_POST['email']); 


        $sql = "SELECT * FROM users WHERE username='" . $username . "'";
        $result = mysqli_query($conn, $sql);
        if(mysqli_num_rows($result) > 0) {
            writeToLogs("UsersAdded.txt", "\n Username exists " . $username);
            echo "username exists";
        }
        else {
            writeToLogs("UsersAdded.txt", "\n Username does not exist, checking email..");
            
            $sql = "SELECT * FROM users WHERE email='" . $email . "'";
            $result = mysqli_query($conn, $sql);
            if(mysqli_num_rows($result) > 0) {
                echo "email exists";
            }
            else {
                writeToLogs("UsersAdded.txt", "\n Email does not exist.");
            }
        }
    }
    else if (isset($_POST['addUser'])) {
        writeToLogs("UsersAdded.txt", "\n\n\n Adding New User... [" . date("Y-m-d h:i:sa", time()) . "]");
        writeToLogs("UsersAdded.txt", "\n ----------------------------------------");


        $username = $conn->real_escape_string($_POST['username']); 
        $email = $conn->real_escape_string($_POST['email']); 
        $password = $conn->real_escape_string($_POST['password']); 
        $team = $conn->real_escape_string($_POST['team']); 


        $sql = "INSERT INTO users (username, email, password, team) VALUES('" . $username . "', '" . $email . "', '" . $password . "', '" . $team . "')";
        $result = mysqli_query($conn, $sql);
        if(!$result) {
            writeToLogs("UsersAdded.txt", "\n " . $username . " could not be added.");
            echo("failure");
        }
        else {
            writeToLogs("UsersAdded.txt", "\n " . $username. " added successfully.");
            echo("success");
        }
    }
    else if (isset($_POST['getUser'])) {
        writeToLogs("UsersRetrieved.txt", "\n\n\n Getting User... [" . date("Y-m-d h:i:sa", time()) . "]");
        writeToLogs("UsersRetrieved.txt", "\n ----------------------------------------");


        $username = $conn->real_escape_string($_POST['username']); 
        $password = $conn->real_escape_string($_POST['password']); 


        $reply = array();
        
        $sql = "SELECT * FROM users WHERE username='" . $username . "' AND password='" . $password . "'";
        $result = mysqli_query($conn, $sql);
        if(mysqli_num_rows($result) > 0) {
            writeToLogs("UsersRetrieved.txt", "\n Successfully retrieved User.");

            while($row = mysqli_fetch_array($result)) {
                $user = array();
                $user["team"] = $row["team"];
            }
            $user["status"] = "success";
            array_push($reply, $user);
        }
        else {
            $user = array();
            $user["status"] = "failure";
            array_push($reply, $user);
            writeToLogs("UsersRetrieved.txt", "\n Username / password combination does not exist: " . $username);
        }

        echo json_encode($reply);
    }


    function writeToLogs($fileToWrite, $textToWrite) {
        $updatedFile = file_get_contents($fileToWrite);
        $updatedFile .= $textToWrite;
        file_put_contents($fileToWrite, $updatedFile);
    }
?>