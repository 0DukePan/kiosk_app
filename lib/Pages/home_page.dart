import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:flutter/material.dart';
import 'package:hungerz_kiosk/Pages/orderPlaced.dart';
import 'package:hungerz_kiosk/Pages/item_info.dart';
import '../Components/custom_circular_button.dart';
import '../Theme/colors.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class ItemCategory {
  String image;
  String? name;

  ItemCategory(this.image, this.name);
}

// Keep FoodItem class as it represents the items available to order
class FoodItem {
  String image;
  String name;
  bool isVeg;
  String price;
  bool isSelected; // Tracks if the overlay/counter is shown on the grid item
  int count = 0;  // Tracks the quantity selected for the cart

  FoodItem(this.image, this.name, this.isVeg, this.price, this.isSelected,
      this.count);
}

// CartItem class is no longer needed as we'll derive cart from foodItems
// class CartItem { ... }

class _HomePageState extends State<HomePage> {
  int orderingIndex = 0;
  // itemSelected tracks if *any* item has been selected to show the bottom bar
  bool itemSelected = false;

  // Remove the dummy cartItems list
  // List<CartItem> cartItems = [ ... ];

  // This list holds all available food items and their state (count, selection)
  List<FoodItem> foodItems = [
    FoodItem(
        'assets/food items/food1.jpg', 'Veg Sandwich', true, '5.00', false, 0),
    FoodItem(
        'assets/food items/food2.jpg', 'Shrips Rice', false, '3.00', false, 0), // Marked non-veg based on image/name
    FoodItem(
        'assets/food items/food3.jpg', 'Cheese Bread', true, '4.00', false, 0),
    FoodItem(
        'assets/food items/food4.jpg', 'Veg Cheeswich', true, '3.50', false, 0),
    FoodItem('assets/food items/food5.jpg', 'Margherita Pizza', true, '4.50',
        false, 0),
    FoodItem(
        'assets/food items/food6.jpg', 'Veg Manchau', true, '2.50', false, 0),
    FoodItem(
        'assets/food items/food7.jpg', 'Spring Noodle', true, '3.00', false, 0),
    FoodItem(
        'assets/food items/food8.jpg', 'Veg Mix Pizza', true, '5.00', false, 0),
  ];
  String? img, name;
  int drawerCount = 0; // 0 for cart drawer, 1 for item info
  int currentIndex = 0; // For category selection
  PageController _pageController = PageController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  // Helper method to calculate total items in cart
  int calculateTotalItems() {
    return foodItems.fold(0, (sum, item) => sum + item.count);
  }

  // Helper method to calculate total amount
  double calculateTotalAmount() {
     return foodItems.fold(0.0, (sum, item) => sum + (double.tryParse(item.price) ?? 0.0) * item.count);
  }

  @override
  Widget build(BuildContext context) {
    // Filter foodItems to get only those in the cart for the drawer
    final List<FoodItem> itemsInCart = foodItems.where((item) => item.count > 0).toList();
    // Recalculate itemSelected based on actual counts
    itemSelected = itemsInCart.isNotEmpty;

    // Updated list with 9 categories using the new images
    List<ItemCategory> foodCategories = [
      ItemCategory('assets/ItemCategory/burger.png', "Burger"),
      ItemCategory('assets/ItemCategory/pizza.png', "Pizza"),
      ItemCategory('assets/ItemCategory/pates.png', "Pasta"), // Assuming 'pates' means Pasta
      ItemCategory('assets/ItemCategory/kebbabs.png', "Kebabs"), // Corrected filename: kebbabs.png
      ItemCategory('assets/ItemCategory/tacos.png', "Tacos"),
      ItemCategory('assets/ItemCategory/poulet.png', "Chicken"), // Assuming 'poulet' means Chicken
      ItemCategory('assets/ItemCategory/healthy.png', "Healthy"),
      ItemCategory('assets/ItemCategory/traditional.png', "Traditional"),
      ItemCategory('assets/ItemCategory/dessert.png', "Dessert"),
    ];
    return Scaffold(
      key: _scaffoldKey,
      // Pass the filtered list to the cart drawer
      endDrawer: Drawer(
        child: drawerCount == 1 ? ItemInfoPage(img, name) : cartDrawer(itemsInCart),
      ),
      appBar: AppBar(
        actions: [Icon(null)],
        toolbarHeight: 100,
        automaticallyImplyLeading: false,
        title: Column(
          children: [
            Row(
              children: [
                Text(
                  "Welcome",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Scroll to choose your item",
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(fontSize: 13, color: strikeThroughColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              children: [
                Container(
                  width: 90,
                  child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      itemCount: 9, // Updated from 8 to 9
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            setState(() {
                              currentIndex = index;
                              // Optional: Animate PageView to the selected category
                              // _pageController.animateToPage(index, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
                            });
                          },
                          child: Container(
                            height: 90,
                            margin: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: currentIndex == index
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).scaffoldBackgroundColor,
                            ),
                            child: Column(
                              children: [
                                Spacer(),
                                FadedScaleAnimation(
                                  child: Image.asset(
                                    foodCategories[index].image, // Use index safely
                                    scale: 3.5,
                                  ),
                                  scaleDuration: Duration(milliseconds: 600),
                                  fadeDuration: Duration(milliseconds: 600),
                                ),
                                Spacer(),
                                Text(
                                  // Ensure name is not null before calling toUpperCase
                                  foodCategories[index].name?.toUpperCase() ?? '',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(fontSize: 10),
                                  textAlign: TextAlign.center, // Added for better text display
                                ),
                                Spacer(),
                              ],
                            ),
                          ),
                        );
                      }),
                ),
                Expanded(
                  child: PageView( // Each page should potentially show different items based on category 'currentIndex'
                                  // For now, all pages show the same 'foodItems' list.
                                  // A real implementation would filter 'foodItems' based on the category.
                    physics: BouncingScrollPhysics(),
                    controller: _pageController,
                    scrollDirection: Axis.horizontal,
                    onPageChanged: (index) {
                      setState(() {
                        currentIndex = index;
                      });
                    },
                    children: List.generate(9, (pageIndex) => buildPage(pageIndex)), // Generate 9 pages, updated from 8
                  ),
                ),
              ],
            ),
          ),
          // Show bottom bar only if itemSelected is true (calculated from itemsInCart)
          itemSelected
              ? Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(10)),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Theme.of(context).primaryColor,
                          transparentColor,
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              // Cancel Order logic
                              setState(() {
                                for (var item in foodItems) {
                                  item.count = 0;
                                  item.isSelected = false; // Reset selection state as well
                                }
                                // itemSelected will be updated automatically in the next build
                              });
                            },
                            child: Text(
                              "Cancel Order",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(fontSize: 17),
                            ),
                          ),
                          // Pass the actual count to the button builder
                          buildItemsInCartButton(context, calculateTotalItems()),
                        ],
                      ),
                    ),
                  ))
              : SizedBox.shrink()
        ],
      ),
    );
  }

  // Update button to accept and display the actual item count
  CustomButton buildItemsInCartButton(BuildContext context, int itemCount) {
    return CustomButton(
      onTap: () {
        setState(() {
          drawerCount = 0; // Ensure cart drawer is shown
        });
        _scaffoldKey.currentState!.openEndDrawer();
      },
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      title: Row(
        children: [
          Text(
            // Display dynamic count
            "Review Order ($itemCount)",
            style:
                Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 17),
          ),
          Icon(
            Icons.chevron_right,
            color: Colors.white,
          )
        ],
      ),
      bgColor: buttonColor,
    );
  }

  // buildPage should ideally filter items based on pageIndex (category)
  // For now, it displays all items from foodItems list
  Widget buildPage(int pageIndex) {
    // Placeholder: In a real app, filter foodItems based on pageIndex/category
    // final categoryItems = foodItems.where((item) => item.categoryIndex == pageIndex).toList();
    // Using the full list for now:
    final categoryItems = foodItems;

    return GridView.builder(
      physics: BouncingScrollPhysics(),
      padding:
          EdgeInsetsDirectional.only(top: 6, bottom: 100, start: 16, end: 32), // Added bottom padding
      itemCount: categoryItems.length, // Use filtered list length
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75), // Adjust aspect ratio if needed
      itemBuilder: (context, index) {
         // Get the specific item for this grid cell
        final item = categoryItems[index];
        return Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).scaffoldBackgroundColor),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 35, // Adjust flex factor if needed
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      // Toggle selection state
                      item.isSelected = !item.isSelected;
                      // If selecting and count is 0, set count to 1
                      if (item.isSelected && item.count == 0) {
                        item.count = 1;
                      }
                      // If deselecting, set count to 0
                      else if (!item.isSelected) {
                        item.count = 0;
                      }
                      // itemSelected = foodItems.any((i) => i.count > 0); // Recalculate overall selection status
                      // itemSelected state is now handled automatically in build method
                    });
                  },
                  child: Stack(
                    children: [
                      FadedScaleAnimation(
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(10)),
                              image: DecorationImage(
                                  image: AssetImage(item.image), // Use item's image
                                  fit: BoxFit.cover)), // Use cover fit
                        ),
                        scaleDuration: Duration(milliseconds: 600),
                        fadeDuration: Duration(milliseconds: 600),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          height: 20,
                          width: 30,
                          child: IconButton(
                              padding: EdgeInsets.zero, // Remove padding
                              icon: Icon(
                                Icons.info_outline, // Use outlined icon
                                color: Colors.grey.shade400,
                                size: 18, // Adjust size
                              ),
                              onPressed: () {
                                setState(() {
                                  // Set details for the ItemInfoPage drawer
                                  img = item.image;
                                  name = item.name;
                                  drawerCount = 1; // Set drawer to show item info
                                });
                                _scaffoldKey.currentState!.openEndDrawer();
                              }),
                        ),
                      ),
                      // Show counter overlay if item is selected OR if count > 0
                      item.isSelected || item.count > 0
                          ? Opacity(
                              opacity: 0.8,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(10)),
                                  gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.center,
                                      colors: [
                                        Theme.of(context).primaryColor,
                                        transparentColor,
                                      ],
                                      stops: [
                                        0.2,
                                        0.75,
                                      ]),
                                ),
                              ),
                            )
                          : SizedBox.shrink(),
                     // Show counter only if item is selected OR count > 0
                      item.isSelected || item.count > 0
                          ? Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 0.0),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 6), // Adjust padding
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              if (item.count > 0) {
                                                 item.count--;
                                                 // If count reaches 0, also update isSelected
                                                 if (item.count == 0) {
                                                   item.isSelected = false;
                                                 }
                                              }
                                              // itemSelected = foodItems.any((i) => i.count > 0); // Recalculate
                                            });
                                          },
                                          child: Icon(
                                            Icons.remove,
                                            color: Colors.white,
                                            size: 18, // Adjust size
                                          )),
                                      SizedBox(
                                        width: 10, // Adjust spacing
                                      ),
                                      CircleAvatar(
                                        radius: 11, // Adjust size
                                        backgroundColor: buttonColor,
                                        child: Text(
                                          item.count.toString(), // Use item's count
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium!
                                              .copyWith(
                                                  fontSize: 11, // Adjust size
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold // Make bold
                                                  ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10, // Adjust spacing
                                      ),
                                      GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              item.count++;
                                              item.isSelected = true; // Ensure item stays selected when incrementing
                                              // itemSelected = true; // Recalculate
                                            });
                                          },
                                          child: Icon(
                                            Icons.add,
                                            color: Colors.white,
                                            size: 18, // Adjust size
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : SizedBox.shrink(),
                    ],
                  ),
                ),
              ),
              // Use Spacer for flexible spacing, adjust flex factors if needed
              Spacer(flex: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  item.name, // Use item's name
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(fontSize: 13), // Adjust font size
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1, // Ensure single line
                  softWrap: false,
                ),
              ),
              Spacer(flex: 4), // Adjust flex factor
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    FadedScaleAnimation(
                      child: Image.asset(
                        item.isVeg // Use item's isVeg status
                            ? 'assets/ic_veg.png'
                            : 'assets/ic_nonveg.png',
                        scale: 2.8, // Adjust scale
                      ),
                      scaleDuration: Duration(milliseconds: 600),
                      fadeDuration: Duration(milliseconds: 600),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      '\$' + item.price, // Use item's price
                      style: TextStyle(fontSize: 13), // Adjust font size
                    ),
                  ],
                ),
              ),
              Spacer(flex: 5), // Adjust flex factor
            ],
          ),
        );
      },
    );
  }

  // Update cartDrawer to accept and use the filtered list of items
  Widget cartDrawer(List<FoodItem> itemsInCart) {
    return Drawer(
      child: SafeArea(
        child: Stack(
          children: [
            FadedSlideAnimation(
              child: ListView(
                physics: BouncingScrollPhysics(),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                "My Order",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                "Quick Checkout",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                        fontSize: 15,
                                        color: strikeThroughColor),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  // Build the list based on items actually in the cart
                  ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      // Add bottom padding to avoid overlap with the bottom summary
                      padding: EdgeInsets.only(bottom: 200), // Increased padding
                      itemCount: itemsInCart.length, // Use dynamic length
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        // Get the current item from the filtered list
                        final cartItem = itemsInCart[index];
                        return Column(
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 10), // Adjusted padding
                              leading: ClipRRect( // Removed GestureDetector
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.asset(cartItem.image, width: 60, height: 60, fit: BoxFit.cover,) // Use item's image
                                    ),
                              title: Padding(
                                padding: const EdgeInsets.only(bottom: 8.0), // Adjusted padding
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Expanded( // Allow text to wrap or ellipsis
                                      child: Text(
                                        cartItem.name, // Use item's name
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium!
                                            .copyWith(fontSize: 15), // Adjusted size
                                        overflow: TextOverflow.ellipsis, // Handle long names
                                      ),
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Image.asset(
                                      cartItem.isVeg // Use item's isVeg
                                          ? 'assets/ic_veg.png'
                                          : 'assets/ic_nonveg.png',
                                      height: 14, // Adjusted size
                                    ),
                                  ],
                                ),
                              ),
                              subtitle: Row( // Keep counter and price on the same line
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 5, horizontal: 8), // Adjusted padding
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                                color: Colors.grey.shade300, // Softer border
                                                width: 1)), // Adjusted border
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            GestureDetector(
                                                onTap: () {
                                                  // Find the corresponding item in the main list to update
                                                  setState(() {
                                                    if (cartItem.count > 0) {
                                                        cartItem.count--;
                                                        // If count becomes 0, itemSelected will be updated in next build
                                                        // No need to explicitly remove here, the filter will handle it
                                                        if (cartItem.count == 0){
                                                            cartItem.isSelected = false; // Also deselect from grid view
                                                        }
                                                    }
                                                  });
                                                },
                                                child: Icon(
                                                  Icons.remove,
                                                  color: Theme.of(context).primaryColor, // Use primary color
                                                  size: 18, // Adjusted size
                                                )),
                                            SizedBox(
                                              width: 10, // Adjusted spacing
                                            ),
                                            Text(
                                              cartItem.count.toString(), // Use item's count
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium!
                                                  .copyWith(fontSize: 14), // Adjusted size
                                            ),
                                            SizedBox(
                                              width: 10, // Adjusted spacing
                                            ),
                                            GestureDetector(
                                                onTap: () {
                                                   // Find the corresponding item in the main list to update
                                                  setState(() {
                                                     cartItem.count++;
                                                     cartItem.isSelected = true; // Ensure selected when count > 0
                                                  });
                                                },
                                                child: Icon(
                                                  Icons.add,
                                                   color: Theme.of(context).primaryColor, // Use primary color
                                                  size: 18, // Adjusted size
                                                )),
                                          ],
                                        ),
                                      ),
                                      Spacer(),
                                      // Display item price (base price, not total for this item)
                                      Text('\$' + cartItem.price, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),)
                                    ],
                                  ),
                              // Remove the 'Extra Cheese' section as FoodItem doesn't have extras
                            ),
                           Divider(indent: 10, endIndent: 10, thickness: 0.5), // Add divider
                          ],
                        );
                      })
                ],
              ),
              beginOffset: Offset(0.0, 0.3),
              endOffset: Offset(0, 0),
              slideCurve: Curves.linearToEaseOut,
            ),
            // Bottom summary section
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom), // Add padding for safe area
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                     Divider(height: 1, thickness: 0.5), // Divider before ordering method
                    Padding( // Add padding around ordering method
                      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(bottom: 10), // Spacing below title
                            child: Text("Choose Ordering Method", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 16)), // Slightly larger title
                          ),
                          orderingMethod()
                        ],
                      ),
                    ),
                     Divider(height: 1, thickness: 0.5), // Divider before total amount
                    ListTile(
                      tileColor: Theme.of(context).colorScheme.surface,
                      title: Text("Total Amount",
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(
                                  fontSize: 16, // Adjusted size
                                  fontWeight: FontWeight.w600, // Slightly bolder
                                  color: Colors.blueGrey.shade700)),
                      trailing: Text(
                        // Calculate and display the dynamic total amount
                        '\$' + calculateTotalAmount().toStringAsFixed(2),
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(color: Colors.blueGrey.shade900, fontSize: 16, fontWeight: FontWeight.bold), // Adjusted size and weight
                      ),
                    ),
                    FadedScaleAnimation(
                      child: CustomButton(
                        onTap: () {
                          // Only proceed if there are items in the cart
                          if (calculateTotalItems() > 0) {
                             Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrderPlaced(),
                              ));
                          } else {
                             // Optional: Show a message if cart is empty
                             ScaffoldMessenger.of(context).showSnackBar(
                               SnackBar(content: Text('Please add items to your order first.'), duration: Duration(seconds: 2),)
                             );
                          }

                        },
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 12), // Adjusted padding
                        margin:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 60), // Adjusted margin
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.center, // Center button content
                          children: [
                            Text(
                              "Place Order",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                            ),
                            SizedBox(width: 8), // Space before icon
                            Icon(
                              Icons.chevron_right,
                              color: Colors.white,
                            )
                          ],
                        ),
                        bgColor: buttonColor,
                        borderRadius: 8, // Less rounded corners
                      ),
                      scaleDuration: Duration(milliseconds: 600),
                      fadeDuration: Duration(milliseconds: 600),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget orderingMethod() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0), // Removed horizontal padding here
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded( // Use Expanded for even distribution
            child: GestureDetector(
              onTap: () {
                setState(() {
                  orderingIndex = 0;
                });
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 5), // Add margin between buttons
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5), // Adjusted padding
                height: 65, // Adjusted height
                decoration: BoxDecoration(
                  color: orderingIndex == 0 ? Color(0xffFFEEC8) : Colors.grey.shade100, // Use grey for inactive
                  borderRadius: BorderRadius.circular(8), // Match button radius
                  border: orderingIndex == 0
                      ? Border.all(color: Theme.of(context).primaryColor, width: 1.5) // Thicker border
                      : Border.all(color: Colors.grey.shade300), // Softer border for inactive
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Center content
                  children: [
                    FadedScaleAnimation(
                      child: Container(
                        padding: EdgeInsets.only(right: 8), // Space between icon and text
                        child: Image(
                          image: AssetImage("assets/ic_takeaway.png"), height: 24, // Adjusted icon size
                        ),
                      ),
                      scaleDuration: Duration(milliseconds: 600),
                      fadeDuration: Duration(milliseconds: 600),
                    ),
                    Text("Take Away", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),), // Adjusted text style
                  ],
                ),
              ),
            ),
          ),
          Expanded( // Use Expanded for even distribution
            child: GestureDetector(
              onTap: () {
                setState(() {
                  orderingIndex = 1;
                });
              },
              child: Container(
                 margin: EdgeInsets.symmetric(horizontal: 5), // Add margin between buttons
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5), // Adjusted padding
                height: 65, // Adjusted height
               // width: MediaQuery.of(context).size.width * 0.35, // Remove fixed width
                decoration: BoxDecoration(
                   color: orderingIndex == 1 ? Color(0xffFFEEC8) : Colors.grey.shade100, // Use grey for inactive
                  borderRadius: BorderRadius.circular(8), // Match button radius
                  border: orderingIndex == 1
                      ? Border.all(color: Theme.of(context).primaryColor, width: 1.5) // Thicker border
                      : Border.all(color: Colors.grey.shade300), // Softer border for inactive
                ),
                child: Row(
                 mainAxisAlignment: MainAxisAlignment.center, // Center content
                  children: [
                    FadedScaleAnimation(
                      child: Container(
                         padding: EdgeInsets.only(right: 8), // Space between icon and text
                        child: Image(
                          image: AssetImage("assets/ic_dine in.png"), height: 24, // Adjusted icon size
                        ),
                      ),
                      scaleDuration: Duration(milliseconds: 600),
                      fadeDuration: Duration(milliseconds: 600),
                    ),
                    Text("Dine In", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15)), // Adjusted text style
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
