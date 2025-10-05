# A simple Roblox Payment Processor [ RPC ]
<sup>idk why the abbreviation doesnt match the actual name</sup>

It has only two purposes! To make the coding experience faster and to **secure**.

With that in mind I can assure no one can breach this;

Why is this different from roblox's API? Its not, its a tiny squeaky bit better than roblox's but its made for begginners to understand how it works and for others to be faster at game making.

# Usage:
### Adding a new product/gamepass to the handler

<img width="238" height="182" alt="image" src="https://github.com/user-attachments/assets/aa70d23c-d8b4-4fe9-bbaa-a9055a0625c6" />

**In products/gamepasses module you ll add a item in the table like this: [name]=id; ( [name:any]=id:number ) ;**

``` LuaU

return{--example
   ['test']=123456;
}

```

**However in the Callbacks module you ll do it like this:**

``` LuaU

return{--example
   [123456]=function(player:Player|Instance)-- the id must match with the one in the gamepasses / products folder
       -- Will get called only when the product has been purchased
   end,
}

```


### Script Usage Example

``` LuaU
local Binder=require(path%to%binder.binder) -- totally optional, instead you can use a simple PlayerAdded event if you dont like this.
local RPC=require(path%to%rpc.rpc).new();

Binder.BindPlayerAdded:Connect(function(player:Player;joined:boolean)
    local signal=RPC:Purchase(player,"gamepass or product name")

    signal:Connect(function()
        print('Purchased!!')
    end)
end)
```
