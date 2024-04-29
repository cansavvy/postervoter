# posterpoller

opensource polling system for poster competitions or other things!

You can [read the posterpoller package documentation here](https://hutchdatascience.org/posterpoller/).

## Install the package

You can install `posterpoller` using the `remotes` package to install from GitHub.

```
if (!("remotes" %in% installed.packages())) {
  install.packages("remotes")
}

remotes::install_github("fhdsl/posterpoller")
```

Then you'll need to load the library. 

```
library(posterpoller)
```

## Set Up 

1. Create a Googlesheet that has the `poster_title` and `presenter_name` as columns: 

[See example here](https://docs.google.com/spreadsheets/d/12aomFyT0zEHNmpyCQoGdDh16P-bRp4Pkt4PCCrU7gYY/edit#gid=0)

Declare it here. 

```
poster_googlesheet <- "https://docs.google.com/spreadsheets/d/12aomFyT0zEHNmpyCQoGdDh16P-bRp4Pkt4PCCrU7gYY/edit#gid=0"
```


2. We'll read in the poster googlesheet to check that we can find it. You'll have to sign in to Google.  

```
googlesheets4::read_sheet(poster_googlesheet)
```

3. Make a new poll with `make_poll()` function. 

```
form_info <- make_poll(new_name = "New Poster Poll")
```

4. In the opened window of the new poll you created, click the vertical "..." for `More options` and choose "Get prefill link".

<img src ="resources/prefill_link_button.png" width=300px">

In this screen, put `{poster_id}` and `{poster_title}` and `{presenter_name}` as the responses respectively.

<img src ="resources/entries.png" width=300px">

Then click "Get Link" on the bottom.

There will be a tiny pop up at the bottom left that says "COPY LINK". Click that button. 

<img src ="resources/copy_link.png" width=200px">

Copy and paste this URL below to declare as an R object. It should look something like the example below. We'll need this for the next step. 

```{r eval = FALSE}
prefill_url <- "https://docs.google.com/forms/d/e/1FAIpQLScPnpDBbXXPSHBnEZeoUjLrx-brFq-bHl5cvQIkeEbDoKROIA/viewform?usp=pp_url&entry.38519462=%7Bposter_id%7D&entry.2095768008=%7Bpresenter_name%7D&entry.1154882998=%7Bposter_title%7D"
```

5. Run generate `generate_poster_ids()` function by putting your `prefill_url` and `poster_googlesheet` into this function. 

Now we can run the function. 

```
generate_poster_ids(prefill_url = prefill_url,
                    poster_googlesheet = poster_googlesheet, 
                    dest_folder = "qr_codes")
```

By default the PNG qr codes are saved to a folder called `qr_codes` and an additional worksheet with the qr_code info and poster_id info is saved to the googlesheet you read in.

You're all set! Print these QR codes out and put them to each poster. 
