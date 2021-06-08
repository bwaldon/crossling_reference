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
        'instructionLine1': '两位玩家，其中一人将担任' + '描述者'.bold() + '另一人则担任' + '猜图者'.bold() + '.',
        'instructionLine2': '在每一轮游戏中，屏幕上展示的物品中有一个是目标，这个目标周围将有一个黑色边框做为标记。只有描述者才能看到这个黑色边框。描述者的任务是向猜图者描述目标物体，以做出正确的选择。而猜图者则需要跟据描述者提供的信息来做出选择。',
        'instructionLine3': "以下是描述者看到的画面示例：",
        'instructionLine4': "描述者，请记住：透露目标物体在屏幕上的位置并不会帮助到您的搭档，因为双方看到的图片顺序是不一样的。",
        'instructionLine5': '您将使用一个聊天窗口与您的搭挡交流。描述者可以打字发消息以帮助对方推断出正确选项；同时，猜图者亦可用聊天窗口对描述者进行提问，以获取更清楚的信息。',
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
        'instructionLine1': "一旦描述者在聊天窗口中发出了一条消息后，猜图者可以开始选择其认为正确的目标图片。猜图者选择完毕后，双方则会看见猜图者做出的选择。 这时，正确的答案将以" + "绿色".fontcolor('green') + "方框圈出。若猜图者选择错误，其做出的错误选择将以" + "红色".fontcolor('red') + "方框圈出。",
        'instructionLine2': "以下是猜图者在上一个例子中做出选择后所看到的画面。在这一轮中，猜图者选择正确。",
        'instructionLine3': "在看到猜图者做出的选择之后，你们将自动进入下一组图片。本游戏一共有72轮。完成72轮后，你们可以选择填写一份简短的问卷，并得到一个 Prolific 参与号码。",
        'previousButtonText': '上一页',
        'nextButtonText': '下一页'
    }
};