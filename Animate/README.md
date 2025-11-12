# Animate!

**This is a simple to use module, which only has **3** methods for simple animation tasks. Its a very easy to use module which I made during a commission; it also returns if the animation ID doesnt work; ( ex. it isnt yours / it isnt sanitized )**

## **Hierarchy**:

**NOTE! Both the animationcontroller and the humanoid MUST contain an animator.**
  
**1. AnimationController Method [ Container -> AnimationController -> Animator ]**:

<img width="237" height="64" alt="Screenshot_2" src="https://github.com/user-attachments/assets/9e2fbaa6-db55-4cae-83d3-002549822fdd" />

**1. Humanoid Method [ Container -> Humanoid -> Animator ]**:

<img width="185" height="62" alt="Screenshot_3" src="https://github.com/user-attachments/assets/5183d641-1cc7-48a4-ae9c-11f86e470319" />

## **Methods**

***1. new***

@params: container       -- can be any container; folder/tool/model; any **Instance**. It loops and plays the anim;

@return: AnimationTrack  -- the playing animation

***2. getAnimator***

@params: container

@return: Animator | nil -- IF exists and if the hierarchy presented above is correct

***3. cancel***

@params: container -- Cancels all the playing animations of the model

@return: nil 
