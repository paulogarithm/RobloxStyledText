# RobloxStyledText
Style your text at runtime on roblox studio with this module !

## How to use ?
1. Import this lua script in roblox studio using Rojo or just by copy-pasting the content in a ModuleScript you created named `StyledText`.
2. Edit your TextLabel with the formatting text

## How to format

### Regular text
Just type normally to have regular text.

If your textLabel contains `Hello world`, it will just not change, and stays the same color as the textLabel had.

### Color name
You can type `&[color]` and replace "color" by the name of your color. <br>
It can be red, blue, green... And any color that exists in the
[BrickColor class](https://create.roblox.com/docs/reference/engine/datatypes/BrickColor#summary-constructors)
or the
[BrickColor names](https://create.roblox.com/docs/reference/engine/datatypes/BrickColor) in the "new" constructor.

The text is case insencitive, meaning you can type using the case that you want, it will always work.

For example `&[red]Hello` will create a red text, `&[RED]Hello` will also create red, and `&[bright reddish violet]Hello` will be bright reddish violet.

### Hex Color
You can color text using [hexadecimal](https://htmlcolorcodes.com/) notation. It can be 3 or 6 characters.

For example, you can create red like thid `&[#f00]Hello` or like that `&[#ff0000]Hello`. 

### Chaining
You can use multiple colors on the same line, thats the pros of this module.

For example, `&[blue]this is blue, &[red]but this is red !`

### Resetting
If you had enough colors, you can decide to reset the colors by using `&&`. It will use the default color of your origin TextLabel.

In this example `Hello &[red]world&& foobar is &[red]here&& !`, only the word `world` and `here` will be colored (here in the example in red)
