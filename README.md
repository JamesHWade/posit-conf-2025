# posit-conf-2025

## Title

Disposable Shiny Apps

## Abstract

Many data scientists find themselves building Shiny apps for one-off presentations, client meetings, or teaching demonstrations. These "disposable" apps can suffer from overengineering, leading to unnecessary development time and complexity. Or, the apps never get built because the development hill is too high to climb. This talk covers disposable Shiny apps - intentionally minimal applications designed for specific, short-term needs. We'll explore strategies for rapid development, including reusable templates, coding assistants, efficient styling, and design principles that prioritize speed and clarity. This talk will show how this approach can transform a typical week-long development process into a few hours while maintaining professional polish.

## Script

Hi, I'm James Wade. I'd like to propose a talk about disposable Shiny apps - creating focused, minimal apps for presentations and demos without getting caught in the complexity trap.

Many of us avoid building Shiny apps for presentations or client meetings because the development hill feels too steep to climb. When we do build them, we often over-engineer solutions for one-off needs.

At posit::conf(2025), I'll share strategies for rapid Shiny development, including reusable templates, coding assistants, and efficient but consistent styling. I'll demonstrate examples from my experience building these short-lived apps, showing how to transform what could be a week-long project into just a few hours.

Attendees will learn when disposable apps make sense, how to build them efficiently, and how to maintain momentum by keeping development time proportional to app lifespan. This knowledge will help them create more interactive presentations without getting bogged down in unnecessary complexity.

Thank you for considering my proposal.

# Session 1

### Key Takeaways from Your First Coaching Session:

The feedback on your talk was very positive. The concept of "disposable Shiny apps" clearly resonates and solves a common problem. Here are the most important points to remember:

1. Reframe the "Why": It’s About Shifting the Audience from Passive to Active.

    Your most powerful argument is that disposable apps transform a presentation. Instead of showing static slides, you are giving your audience a tool to explore, ask questions, and participate in the data. The goal isn't just to build an app; it's to change the nature of the conversation.

2. Address the Key Tensions Head-On.

    The group brought up the exact objections your audience will have. You should address them directly in your talk:

    - **The Fear of "App Sprawl":** Acknowledge the risk of creating hundreds of messy, unsupported apps. Clearly define that these are **communication tools, not production dashboards**, and should be treated like a whiteboard sketch—valuable in the moment, and erasable afterward.

    - **The "Who Will Support It?" Question:** Frame this as a feature, not a bug. The answer is "No one, and that's the point." Because it only took an hour to build, it doesn’t need a support infrastructure. You can just build it again.

    - **The Value of Interactivity:** Use the story suggested in the session: when a stakeholder asks, "Can we see that data split a different way?" an app can answer that instantly, while a slide deck can't.

3. Show, Don't Just Tell—The "Magic" is the AI Assistant.

    The idea of "vibe coding" and using AI assistants is your hook and your proof. The most compelling part of your presentation will be demonstrating how quickly you can turn a plain English prompt into a functional Shiny app. This single action proves that the "development hill" is no longer too steep.

4. Tell Relatable Stories.

    Your personal stories and the examples from the group are what will make the talk memorable:

    - **Your Opening Hook:** Your promise to "never make slides for a manager again" is provocative and relatable. Use it.

    - **The Fun Example:** The idea of building a fun, silly app (like organizing your four cats) is a brilliant way to make the process seem approachable and low-stakes. It proves that not every app has to be a serious, complex project.

    - **The Power of the App vs. the Slide:** Contrast the interactive, exploratory experience of an app with the frustration of a static, unchangeable chart in a slide deck.


In short, your session confirmed you have a great topic. For your next session, focus on building an outline that tells this story: the old way is broken (static slides), there's a new, better way (disposable apps), the technology is finally here to make it easy (AI assistants), and here’s how you can start doing it today.

## Session 2

### 1. Proposed Talk Outline

The first coaching session revealed the key tensions and selling points of your idea. A strong outline will address these head-on. Here’s a proposed structure you can walk your cohort through:

**Title:** Disposable Shiny Apps

**Introduction (The Hook)**

- **State the Goal:** "My goal today is to convince you that you should build more Shiny apps, and then throw them away."
    - Add something to say who I am, justify this a bit
    - Be trustworthy
- See dedicated section below.
- **Introduce the Core Idea:** Propose a new mindset. What if building an app for a single meeting was as easy as making a slide deck? Introduce the term "Disposable Shiny App."

#### Part 1: The Problem with the Status Quo (~4 mins)

- The Two Traps
    1. **The "Don't Build" Trap:** The perceived effort of building a Shiny app is too high for a "simple" meeting, so we default to slides.
    2. **The "Over-Build" Trap:** We build an app but over-engineer it, creating a complex solution for a simple need.
- The Consequence: Death by PowerPoint.
    - **Story:** Share a brief, relatable story of being in a meeting where a simple "what-if" question couldn't be answered because the data was locked in a static slide.
    - **Key Idea:** We trap our insights instead of enabling exploration. We turn our audience into passive observers.

#### Part 2: The Solution: A New Mindset & New Tools

- The Disposable App Philosophy
    - Its value is in its immediate impact, not its longevity.
    - It’s a communication artifact, not a production system.
- The Game Changer: AI Coding Assistants.
    - This is where I can show, not just tell.**
    - App Demo/Video Clip - I could use a tool like the Positron Assistant to do some "vibe coding." Take a simple prompt and show it generating the code. Need to think of a good fit for this.

#### Part 3: A Practical Guide to Build a Disposable App

Step through the demo as we go through the steps.

- **Step 1: Start with One Question: "Who is hungry? -> let's do better here".** Your app should do one thing well. What is the one question you want your audience to explore? This re-frames "thinking" from slide design to interaction design.
- **Step 2: Use a Template.** Don't start from scratch. Show a minimal, reusable `app.R` template.
- **Step 3: Style in Seconds.** Briefly mention how `bslib` and a `brand.yml` file can give you a professional look in minutes, not hours.
- **Step 4: Build Your Story App (The Fun Demo!).**
    - This is where you build your fun, memorable app. The cat-themed idea was a hit in the coaching session!
    - **Example Idea:** "The Cat Chaos Coordinator" - An app to decide which of your four cats gets attention next, with inputs for "Cuteness Level" and "Last Petting Time." It’s silly, memorable, and demonstrates the principles perfectly.
#### Part 4: Overcoming the Objections

- **Objection 1: "But who will support it?"**
    - Story/Analogy: Use your story about the IT department. Frame it with an analogy: "You don't need a maintenance crew for a whiteboard drawing. You just erase it. This is the same thing."
- **Objection 2: "Won't this create hundreds of messy apps?"
    - **Acknowledge & Reframe (Claudia's point):** Acknowledge the risk of "app sprawl." Clarify the distinction: these are not production dashboards. They are communication tools. They live alongside, not in place of, permanent, supported applications.
    - *throw it away* (I might be the wrong one to ask)
- **Objection 3: "This sounds like more work!"**
    - **Directly Counter:** Show a side-by-side comparison of the time spent tweaking a 20-slide deck versus iterating on a simple app. Argue that the impact-to-effort ratio is much higher with the app.
    - For me, this works, but it might not be true for you
    - Fun work goes by faster

#### Conclusion & Call to Action

- Recap: The barriers are gone because new tools are here. AI coding assistants are part of this, but even without them, it is so much easier to build shiny apps. The only thing left is to change our **mindset**.
- Call to Action: "The next time you have a presentation, I challenge you: open your R session before you open PowerPoint. Build a doorway for your audience, not a wall."

### 2. Opening ~~Hook~~ Metaphors and Asides

Your hook needs to grab the audience immediately and introduce the central conflict. Here are three options based on your first session:

1. **The Bold Proclamation (Your Story):**

    > "I've made a promise to myself: I am never making slides for a manager ever again. That might sound crazy, but by the end of this talk, I hope you'll consider making the same promise. I'm here to talk about a powerful alternative: the disposable Shiny app."

2. **The Relatable Question (Interactive):**

    > "Raise your hand if, in the last month, you've been in a meeting, looked at a chart on a slide, and thought, 'But what if we just filtered for X?' or 'How would that look if we split it by Y?'… Now, keep your hand up if you got an answer right there in the room… My goal today is to give you the tools to make sure every hand in the room stays up."

1. **The Analogy (Visionary):** Art Museum vs Kid's Museum

    > "For years, we've treated our data insights like paintings. We analyze them, frame them perfectly on a slide, and hang them in a gallery called a presentation for people to look at. But what if we started treating them like clay instead? Something our audience can touch, shape, and explore with us? Today, we're going to get our hands dirty."


---

### 3. Compelling Stories & Data

Your "data" is the qualitative experience of building and using these apps. Your stories will be more compelling than any chart.

- **The "Different Split" Story:** This is your strongest, most concrete use-case. Frame it exactly as Flávia suggested: a stakeholder asks to see the data differently, and with an app, you can do it instantly. This is a clear "before and after" narrative.

- **The "Vibe Coding" Demo:** The most compelling data you have is showing how quickly a natural language prompt becomes a working app. This directly proves your thesis that the barrier to entry has collapsed.

- **The "Cat Chaos Coordinator" App Story:** Frame the development of your fun demo app as a story. "My house is run by four cats. Deciding who gets attention is a high-stakes data problem. So I took 15 minutes and built this…" It makes the process feel approachable, fun, and non-intimidating.

- **The "Who Supports This?" Anecdote:** Use your own story. It's a perfect way to introduce and dismantle a major institutional fear that many in the audience will have experienced. It shows you understand their world and have a practical, if slightly cheeky, solution.
