# Widget Survey

The widget survey allows you to have a quick way to get feedback on your website. [See demo here](https://c-savonen.shinyapps.io/widget-survey/?course_name=widget_repo)

The html looks like this:

```
<center>
<div class="container">
  <iframe class="responsive-iframe" src="https://c-savonen.shinyapps.io/widget-survey/?course_name=widget_survey" style="width: 300px; height: 200px; overflow: auto;"></iframe>
</div>
  </div>
</center>
```

Where you can set `course_name` to what you'd like to be recorded.

Here's the rough description of how you'd set up your own widget survey you'd do the following:

1. Clone this repo.
2. Change the Rmd so that it points to your own Googlesheet where you'd like responses to be recorded.
3. Run this Rmd interactively the first time and set up your google creds.
4. Publish this Shiny app to the location of your choice. For the current example, I used rsconnect because it was free.
5. Then put the URL of your published Shiny app in the code given above.
6. In the website where you'd like to put this, set the `course_name` to what you'd like to be recorded in your Googlesheet.
