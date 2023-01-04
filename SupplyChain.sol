pragma solidity ^0.6.0;

contract SupplyChain {
    // Define the struct for a product
    struct Product {
        uint id;
        string name;
        string capacity;
        string color;
        uint quantity;
        uint price;
        bool state;
    }
    struct Tracking {
        uint id;
        string location;
        string shopName;
        string buyerName;
        string timeArrived;
        bool[4] state ;
    }
    bool productTemp_state = false;
    bool[4] temp_state = [false, false, false, false];

    // Define a mapping from product ID to product struct
    mapping(uint => Product) public products;
    mapping(uint => Tracking) public trackings;

    // Keep track of the next product ID to use
    uint public nextProductId;

    // Event to log when a product is created
    event orderCreated(uint id, string name, string capacity, string color, uint quantity, uint PriceOfProduct);
    event orderPaid(uint id, string name, string capacity, string color, uint quantity, uint PriceOfProduct);
    event sellerInfo(uint id, string location, string shopName);
    event buyerReceived(uint id, string buyerName);
    event courierInfo(uint productId, string location, string timearrived);

    event ParcelDelivered(string message);
    event ParcelNotDelivered(string message);
    // Constructor to set the contract
    constructor() public {
   
}
    // Function to create a new product order
    function orderProduct(string memory Name, string memory Capacity, string memory Color, uint Quantity, uint PriceOfProduct) public {
        // Increment the next product ID
        nextProductId++;

        // Create a new product struct and store it in the mapping
        products[nextProductId] = Product(nextProductId, Name, Capacity, Color, Quantity, PriceOfProduct, productTemp_state);

        // Emit an event to log the creation of the product
        emit orderCreated(nextProductId, Name, Capacity, Color, Quantity, PriceOfProduct);

       products[nextProductId].state = true;
    }

    //Payment
    function paymentByBuyer(uint productId, uint priceToPay) public {
        //If the order is not created yet, return false
        require (products[nextProductId].state == true,"Cannot pay anything before creating order");

        //If the amount of payment is not equal, return false
        require(products[nextProductId].price == priceToPay,"Need to pay the exact amaount of the price");

        // retrieve from struct product
        Product storage product = products[productId];

         //store the variable to be retrieved
        string memory Name = product.name;
        string memory Capacity = product.capacity;
        string memory Color = product.color;
        uint Quantity = product.quantity;

        products[nextProductId] = Product(nextProductId, Name, Capacity, Color, Quantity, priceToPay, productTemp_state);

        emit orderPaid(nextProductId, Name, Capacity, Color, Quantity, priceToPay);

        trackings[nextProductId].state[0] = true;
    }

    //Seller
    function seller(uint productId, string memory location, string memory shopName, string memory buyerName) public {
        //If the product is not paid yet, return false
        require(trackings[nextProductId].state[0] == true,"Seller cannot receive order before payment is done by buyer");

        string memory timeArrived;

        trackings[nextProductId] = Tracking(nextProductId, location, shopName, buyerName, timeArrived, temp_state);
        emit sellerInfo(productId, location, shopName);
        
        trackings[nextProductId].state[1] = true;
    }

    //Courier
    function courier(uint productId, string memory location, string memory timearrived) public {
        require(trackings[nextProductId].state[1] == true,"Cannot send to courier if no seller");
      
        // Retrieve the trackings struct from the mapping
        Tracking storage tracking = trackings[productId];

        //store the buyerName and shopName to be retrieved
        string memory buyerName = tracking.buyerName;
        string memory shopName = tracking.shopName;

        trackings[nextProductId] = Tracking(nextProductId, location,  shopName, buyerName, timearrived, temp_state);
        emit courierInfo(productId, location, timearrived);

       trackings[nextProductId].state[2] = true;
    }

    // Receiver
    function receiver(uint productId, string memory location, string memory recipientName, string memory timeArrived) public {
        require(trackings[nextProductId].state[2] == true,"The parcel still not delivered by courier");

        // Retrieve the trackings struct from the mapping
        Tracking storage tracking = trackings[productId];

        // Encode the string variables as bytes and hash them
        bytes32 productBuyerHash = keccak256(abi.encodePacked(tracking.buyerName));
        bytes32 buyerHash = keccak256(abi.encodePacked(recipientName));

        // Check that the hashed buyer names are the same
        require(productBuyerHash == buyerHash, "Only the Buyer can receive the product");

        string memory shopName = tracking.shopName;
        //string memory recipientName = tracking.buyerName;

        // Check last location
        trackings[nextProductId] = Tracking(nextProductId, location, shopName, recipientName, timeArrived, temp_state);

        // Emit an event to log for the receiver
        emit buyerReceived(productId, recipientName);
    }
    
 }
