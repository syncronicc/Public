# Round Manager;

I am gonna get straight to the point this time because its pretty straight forward. You can create round systems ( Example: " Intermission, Round, Summary " ) which are very easy to manage.

This module does not contain many utils but it should help anyone with small games that dont need to be extended to a more sofisticated module;

NOTE: It does not contain a **END**/**Pause** method yet;

## Usage

### The parameters required to create a new Round;

**#1: States [ table; Optional ];**

This defines all the stages within the round;

Short elaboration: ***[order]={ Name:string ; Timer: number }***; where order is a number and the table contains a **Name** and **Timer** ( Name is the Title and the Timer is the time until the state ends ).

```luau
local States={
  [1]={
    Name='Intermission';
    Timer=60;
  };
  [2]={
    Name='Round';
    Timer=120;
  };
  [3]={
    Name='Summary';
    Timer=60;
  };
}
```

**#2: Looped [ boolean; Required ]**

Can be either false or true. When all the **States** have ended it will: delete the round system and fire a signal if false **OR** it will start again from the first state.

### Creating a new Round
Remember to select the path to your module; This will include the parameters from above.
``` LuaU
local RoundManager=require(path%to%module)
local Round=RoundManager.new(States,true)
```

### Changing the current state to a new one;

Remember the Name from the second parameter? Thats also an identifier

<img width="281" height="91" alt="image" src="https://github.com/user-attachments/assets/11efc0d8-3d7b-492e-9101-5a67c8429004" />

By using this method and passing thru the Name; The current state will cancel and a new one will begin.

``` LuaU
 
Round:SetState('Intermission')
 
```

### Fetching the current state;

If you need to know the current state for some reason; You can use the ***GetState*** method!

``` LuaU
 
Round:GetState()
 
```
### Signals

***Ticking*** Signal will fire every second of the current state that passes;

``` LuaU
 
Round.Ticking:Connect(function(data)
    print(data)
end)
 
```

Ouch! I didnt specify what the data param sends. It doesnt just send the current time of the state, it also contains the Title for extra info.

**@param data:**
``` LuaU
Timer:number;
Title:string;
```

***RoundEnded*** Signal will fire everytime the whole round ends. It will only do it once looped is set to false.

``` LuaU
 
Round.RoundEnded:Connect(function()
    print('Round ended!')
end)
 
```

***StateEnded*** Signal will fire once the state ends; 

``` LuaU
 
Round.StateEnded:Connect(function()
    print('A state has just ended!')
end)
 
```

***StateBegan*** Signal will fire whenever a new state started; it will send the name of the state that started.

``` LuaU
 
Round.StateBegan:Connect(function(name:string)
    print(`A state has just started! [ {name} ]`)
end)
 
```

## Conclusion

I wrote the code faster than I documented it...
