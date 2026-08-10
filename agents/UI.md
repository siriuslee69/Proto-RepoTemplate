## UI guidelines

If given the prompt to create a UI without specifics, you are to create it with the nim-webui library, using vanilla javascript, html and css. The UI should adhere to the following principles.

## UI 

The UI should contain a main element which holds the interactable and viewable content.
Hovering over it on the left, top, right and bottom should be floating panels which either act as menus or panels. 
Panels:
    Panels hold options and settings, contain interactable sliders, buttons, checkboxes and input fields. 
    Panels have to be scrollable and well sorted. Depending on how many options there are, they should themselves have a tiny menu/tab system floating next to them or over them. 
    Checkboxes should only feature one or two words as a description, inline with the checkbox and the font should be small.
    Input fields should only feature one or two words as a placeholder inside them as a description.
    Dropdowns should only hold a placeholder as a description inside them.
    Additionally, all of these elements should have tooltips that show upon hover more detailed information.
Menus:
    Menus mainly hold buttons and searchbars, with each button consisting of two elements: An icon and the actual text.
    The searchbar also should feature an icon and placeholder text inside the searchbar.

Panels and elements by default should have slightly rounded corners and a slightly transparent black background. 
Menus on the left and on the right should collapse to only their icon by default and show the text upon hovering over them.

## Extended Mode vs Compact Mode

Extended mode means greater width than height of the current window.
Compact mode means greater height than width.
In compact mode the left and right panels will be hidden and appended as small buttons in the top menu.
Upon hovering over these buttons, the left and right panel will be shown.

## Android/Touchscreen behaviour

Open panels/extended panels are meant to automatically collapse when pressing somewhere else on the screen (outside the panel).
The menus (top and bottom menu) should always be offset inwards a bit so the native android/mac navigation doesnt block it.
Pressing the back button should not close the app, but close the current opened panel and skip back to the main menu. 
Input fields and their confirmation button should sit on top of the native keyboard popup. This means they have to move/float upwards when active.
Pressing anywhere else in the app will deselect an input field. This should also hide the active, blinking cursor inside it, but not the entered text.
All input fields should feature a small "x" on the left side inside them that deletes the entered text when pressed. 

## UI Loginscreen

If the app is profile based (most apps are) it should have a login screen.
There should be a top menu with three options to choose from:
Register, Login, Recover
The login form itself should be a three column, two row grid inside a card. Each column belongs to either the login, register or recover navigation buttons.
When the login nav is active, the middle most column should contain a scrollable list of already available accounts to click on in the top row - with each of them showing a profile image on the left and the name on the right. 
The bottom row should hold a big plus which, when pressed, will switch to the Register column (so there are two ways to get there - over the top menu or the plus button).
This Register form will then be inside the left most column of the grid and span across the upper and bottom row.
The register form should hav ea big Register button at the bottom and will generally ask for password twice, have a show password eye button on the right and all inputs should have placeholders instead of actual descriptions next to them.
Placeholders should always be slightly transparent.

## Style
- All input fields should have no background, and important input fields (not search) should have a bottom background-image border with a radial gradient that is transparent at the outside and colored on the inside.
- Set padding and margin to 0 for all containers and use center aligning and justifying only. You may only use padding if a container has a lot of text inside it.
- Grid gaps should be kept to a minimum or left out entirely (0px - 5px).
- Set border-radius to 0px or close to 0px for all containers. If you do use rounded corners, use them on singular corners only as highlighting or use a very shallow rounded border as a general base (0.5px-2px).
- Make sure to align the scrollbars color to the rest of the UI theme colors.
- By default ther eshould be no borders anywhere (unless stated explictely).
- Keep panels etc. "floating" - detached from the edges of the window.
- Use backdrop-filter blur of 5-10px for most elements.
- The background color of the body should be a smooth gradient that starts with a dark, unsaturated color in the top left and goes towards a grey white in the bottom right.
- Input fields and buttons should have no backgrounds - unless they are extremely important (grabbing user attention)
- Add animations everywhere (transition animations of 0.3s for hovers/collapsing/color change/extending)
- In general, go for hyper minimalistic/simplistic UI design and get rid of unnecessary text/explanations/descriptions of any kind.
- Elements and buttons displayed as a column list should always have a fixed height - they should never stretch across the entire available space. Their wrapping container should fit them/its content (if its a fixed number of items) or itself have a fixed height as well (if the item count can increase/decrease). If the item count can change, then there should be either a scrollbar or pages through which the user can click to see all items.

## UI Theming

Define colors somewhere at a top level in the css and then reuse them strategically.

By default, use these colors:
#36434e;
#a9b6c2;
#548f9e;
#517093;
rgba(145, 75, 116, 0.9);
Use white and black colors with high transparency and stark backdrop blur for the main content and the menus.

Dropdown menus are often white, make sure you change their backgrounds so the fonts dont accidentally become white on white.


## UI Seperation and visibility

Create the following color definitions:
- `glue` colors that group elements by function/attribute (e.g.: menu/tags from data/elements) <- these should be used for backgrounds, shadows, small, one-sided borders
- `separator` colors that separate big chunks/parts of the menu from other parts ( e.g.: different sections in the main-content) <- these should be used for big straight lines between elements as borders for example.
- `recommendation` colors grab the users attention and guide him through the UI (e.g.: first-time setup/common settings) <- these should be used for badges or background colors/gradients with one end being transparent.
- `tiny` colors that highlight smaller parts of the UI, to make up for their size by color (e.g.: badges) <- these should be used for badges or font shadows
- `active` colors that highlight active/selected elements <- these should be used for font-colors and backgrounds. A common tactic is to invert the regular color. Though that might be a bit too aggressive in some cases.

Define these colors and their appliances in advance and then use them throughout the UI to guide the user strategically.

## Badges

Create the following badges by default:
- circle badge
- diamond badge
- square badge
- diamond with rounded left and right border radius
Additionally, color badges with multiple colors:
- one-sided border color
- background color
- font color (badges should only hold one character at most)

You do not have to use all of them.

## UI Clutter

Keep the displayed information minimal - do not use descriptions/titles in div-boxes. The place for them to exist should be as tooltips only.
The user should understand the purpose of any element by placement, coloring, markers and the actual information inside the panel only.

## UI Strategy

Before you start writing the UI, identify these things:
- What kind of data will the user handle? (table-like data/json-like data/text/images/references to data/videos)
- Will the user handle multiple kinds of data? (then maybe each menu needs to have different visuals for the data)
- How should it be displayed? (List/Grid/Cards)
- What are the main things that user wants to do with the data? (Read/Sort/Edit/Share/Share parts of it)
- Which parts of the data need to be read/edited/shared/sorted?
- Should these functions be implemented per data-element or activate for all elements simultaneously or both via different buttons?
- Where should the buttons live?

## UI Functions

In general, for the data-elements, we decide between two different functions:
1. Functions that only effect one data-element (edit/tag)
2. Functions that effect multiple data-elements (sort/filter)

Functions that effect only one data-point/element should have their button located in a menu that is close to the element or on the element itself. Alternatively, if there is a section that specifically only exists to show a menu/details that are data-element specific, then these kinds of buttons can live their as well.

Functions that effect multiple data-elements should live in a space somewhere that is shared by all data-elements of the current main-content.

## UI File Structure

The respective .js or .ts files should be split by functionality, such that they dont grow too big. Do the same for the .html and .css files.
Refactor when needed.
Always create two nimble tasks for the UI - one so I can run it and one so I can build it for production/release.