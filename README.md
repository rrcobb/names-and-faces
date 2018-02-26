# Student Faces Flashcards CLI

## Setup

### Prerequisites:

* some version of ruby (tested on 2.3.3)

* [iterm2](https://iterm2.com/index.html)

**Note:** This little app _requires_ iterm2. It uses iterm's inline images feature, which is almost guaranteed to break in other terminals. Sorry folks!

### Instructions

1. Clone

```bash
git clone [this repo]
```

2. Data

Put photos into `./data/students` and name the photos like `first_last_profile.jpg` or `first_last_profile.png`

3. Play

**TLDR;** run `./flash.rb` or `ruby flash.rb` from the terminal.

`quit` or `[control + c]` to quit. This will save your game
`show score` from in the game will print out your current score

** Fun Description **
An image appears! You try to guess the name -- Oh, the joy of victory, Oh, the anguish of defeat.

But wait... Another image? Could it be? Another person, another chance!

Keep going, you're sure to get the hang of these in no time!

Perfect for learners of all ages.

**Tips and easter eggs**:

* `show score` from in the game will print out your current score
* `save` will save, but not quit
* `$ rm ./data/score` from the terminal will reset your score
* Changing the names of the students in the data folder will result in great confusion
