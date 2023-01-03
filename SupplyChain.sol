pragma solidity ^0.6.0;

contract SupplyChain {
    // Define the struct for a product
    struct Product {
        uint id;
        string name;
        string capacity;
        string color;
        uint quantity;
        string buyerName;
    }

    // struct Seller{
    //     uint id;
    //     string location;
    //     string shopName;
    // }

    bool[4] state = [false, false, false, false];

    // Define a mapping from product ID to product struct
    mapping(uint => Product) public products;

    // Keep track of the next product ID to use
    uint public nextProductId;

    //Keep track where does the product last location
    string public tracking;

    // Event to log when a product is created
    event ProductCreated(uint id, string name, string capacity, string color, uint quantity, string buyerName);
    event sellerInfo(uint id, string location, string shopName);
    event buyerReceived(uint id, string buyerName);
    event courierInfo(uint productId, string location, uint timearrived);
    // Constructor to set the contract
    constructor() public {
   
}
    // Function to create a new product
    function createProduct(string memory Name, string memory Capacity, string memory Color, uint Quantity, string memory BuyerName) public {
        // Increment the next product ID
        nextProductId++;

        // Create a new product struct and store it in the mapping
        products[nextProductId] = Product(nextProductId, Name, Capacity, Color, Quantity, BuyerName);

        // Emit an event to log the creation of the product
        emit ProductCreated(nextProductId, Name, Capacity, Color, Quantity, BuyerName);

       state[0]=true;
    }

    //Seller
    function seller(uint productId, string memory location, string memory shopName) public {
        
        // // Retrieve the product struct from the mapping
        // Product storage product = products[productId];
    tracking = location;
    emit sellerInfo(productId, location, shopName);
    }

    //Courier
    function courier(uint productId, string memory location, uint timearrived) public {
        tracking = location;
        emit courierInfo(productId, location, timearrived);
    }

    // Receiver
    function receiver(uint productId, string memory buyerName) public {
        // Retrieve the product struct from the mapping
        Product storage product = products[productId];

        Seller storage trackingNo = tracking[productId];
       // Encode the string variables as bytes and hash them
        bytes32 productBuyerHash = keccak256(abi.encodePacked(product.buyerName));
        bytes32 buyerHash = keccak256(abi.encodePacked(buyerName));

        // Check that the hashed buyer names are the same
        require(productBuyerHash == buyerHash, "Only the Buyer can receive the product");
    
        // Emit an event to log for the receiver
        emit buyerReceived(productId, buyerName);
        require(state[0]==true, "Create the product first");
    }
    
 }