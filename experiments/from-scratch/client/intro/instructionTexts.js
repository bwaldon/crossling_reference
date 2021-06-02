export const instructionLanguage = 'English';

export const instructionsStepOneTexts = {
    'English': {
        'instructionTitle': 'Game instructions (part 1 of 3)',
        'instructionLine1': 'Please read these instructions carefully! You will have to pass a quiz on how the game works before you can play!',
        'instructionLine2': 'In this experiment, you will play a guessing game with another person! On each round, both of you will see a set of pictures, like this: ',
        'instructionLine3': 'You and your partner will each see the same pictures, but in different orders.',
        'previousButtonText': 'Previous',
        'nextButtonText': 'Next'
    },

    'ChineseSimplified': {
        'instructionTitle': '游戏说明 (1/3)',
        'instructionLine1': '请仔细阅读以下说明。您只有通过一个检查您对游戏说明的理解测试才能开始游戏。',
        'instructionLine2': '在这个实验中，您将和另一个人玩一场猜图游戏。每一轮，您和您的搭档都将看到如下一组图片: ',
        'instructionLine3': '您和您的搭档将会看到一样的四张图片，但你们看到的图片顺序是不一样的。',
        'previousButtonText': '上一页',
        'nextButtonText': '下一页'
    }
};

export const instructionsStepTwoTexts = {
    'English': {
        'instructionTitle': 'Game instructions (part 2 of 3)',
        'instructionLine1': 'One partner will be assigned the role of ' + 'director'.bold() + ' and the other will be the ' + 'guesser'.bold() + '.',
        'instructionLine2': 'On each round, one of the objects is the target, which is highlighted with a black box. Only the director can see this black box. The task of the director is to tell the guesser which of the objects is the target. The guesser, in turn, needs to select the target object based on the information provided by the speaker.',
        'instructionLine3': "Here's a sample round from the director's perspective:",
        'instructionLine4': "Remember that it doesn’t make sense for the director to describe the location of the target object, since the order of the images is different for the director and the guesser.",
        'instructionLine5': 'You will use a chat window to communicate with your partner. The director can use the chat to help the guesser identify the target, and the guesser can use the chat to ask for clarification from the director.',
        'previousButtonText': 'Previous',
        'nextButtonText': 'Next'
    },

    'ChineseSimplified': {
        'instructionTitle': '游戏说明 (2/3)',
        'instructionLine1': '两人其中一人将会担任 ' + '描述者'.bold() + '另一人将会成为 ' + '猜图者'.bold() + '.',
        'instructionLine2': '在每一轮游戏中，四个图片所展示的物品有一个是目标，这个目标会被一个黑色边框圈出来。只有描述者才能看到这个黑色边框。描述者的任务是向猜测者描述目标物体来做出正确的选择。而猜测者则需要跟据描述者提供的信息来做出选择。',
        'instructionLine3': "以下是描述者看到的画面示例：",
        'instructionLine4': "描述者请记住分享目标物体的图片位置并不会帮助到您的搭档，因为你们两人看到得图片顺序是不一样的。",
        'instructionLine5': '你们需要用到一个聊天窗口来和搭档交流。描述者可以通过在聊天窗口打字发消息来帮助对方猜测正确选项，而猜测者可以在聊天窗口对描述者进行提问获得更清楚的信息。',
        'previousButtonText': '上一页',
        'nextButtonText': '下一页'
    }
};

export const instructionsStepThreeTexts = {
    'English': {
        'instructionTitle': 'Game instructions (part 3 of 3)',
        'instructionLine1': "Once the director sends a message and the guesser selects the object they believe to be the target, both partners are briefly shown which object the guesser clicked on. At this stage, the correct image is highlighted in " + "green".fontcolor('green') + ". If the guesser selects an incorrect image, that incorrect selection will be highlighted in " + "red".fontcolor('red') + ". ",
        'instructionLine2': "Here's the guesser's perspective from the round you just saw. On this round, the guesser correctly identified the target:",
        'instructionLine3': "After reviewing the guesser's selection, you will both be automatically forwarded to the next round of objects. There are a total of 72 rounds. After the 72nd round, you will fill out an optional brief survey and receive a participation code to enter on Prolific.",
        'previousButtonText': 'Previous',
        'nextButtonText': 'Next'
    },

    'ChineseSimplified': {
        'instructionTitle': '游戏说明 (3/3)',
        'instructionLine1': "一旦描述者在聊天窗口中发出了一条消息后，猜测者可以开始选择他们认为的正确目标。当猜测者选择完毕后，两人都会看见猜测者做出的选择。 这时，正确的答案将会被一个" + "绿色".fontcolor('green') + "方框圈出。如果猜测者选择错误，其所做出的错误选择将会被一个" + "红色".fontcolor('red') + "方框圈出。",
        'instructionLine2': "以下是猜测者在上一个例子中做出选择后所看到的画面。在这一轮中，猜测者选择正确。",
        'instructionLine3': "在看到猜测者做出的选择之后，你们将自动进入下一组图片。本游戏一共有72轮。当你们完成72轮后，你们将可以选择填写一份简短的问卷，并得到一个Prolific的参与号码。",
        'previousButtonText': '上一页',
        'nextButtonText': '下一页'
    }
};