library(gmailr)
library(dplyr)
library(googlesheets)

# get googlesheet data
sheet <- gs_title("CascadiaRConf-Submissions")
dat <- gs_read(sheet, ws = "Ratings summary")
dat <- dat %>% mutate(decision_bool = !is.na(as.numeric(Decision)))

full_talks <- dat %>% filter(grepl("Full talk", `Proposal Type`), decision_bool)
full_talks_accepted <-
  full_talks %>%
  select(`First Name`, `Last Name`, `Talk Title`, email) %>%
  apply(., 1, as.list)

full_talks_no <- dat %>% filter(grepl("Full talk", `Proposal Type`), !decision_bool)
full_talks_notaccepted <-
  full_talks_no %>%
  select(`First Name`, `Last Name`, `Talk Title`, email) %>%
  apply(., 1, as.list)


light_talks <- dat %>% filter(grepl("Lightning", `Proposal Type`), decision_bool)
light_talks_accepted <-
  light_talks %>%
  select(`First Name`, `Last Name`, `Talk Title`, email) %>%
  apply(., 1, as.list)

light_talks_no <- dat %>% filter(grepl("Lightning", `Proposal Type`), !decision_bool)
light_talks_notaccepted <-
  light_talks_no %>%
  select(`First Name`, `Last Name`, `Talk Title`, email) %>%
  apply(., 1, as.list)



# email text
email_text_accepted <- "Hi %s

Congratulations, your CascadiaRConf talk submission '%s' has been accepted!

We're looking forward to your talk!

We'll follow up with more details soon.

Let us know by May 11th if you change your mind - so we can give your slot to
someone else. This is a small conference and we'd like to make sure all
spots are filled.

Do remember to purchase a ticket at https://www.eventbrite.com/e/cascadia-r-conference-tickets-33779595680

Sincerely,
CascadiaRConf Organizers
(sent using `gmailr`)
"

email_text_not_accepted <- "Hi %s

Thank you so so much for your submission. However, we regret to say that
your CascadiaRConf talk submission '%s' was not accepted.

We hope you still would like to attend :)  And we hope to run this event next year, so they'll be another chance then.

If you want to buy a ticket you can do so at https://www.eventbrite.com/e/cascadia-r-conference-tickets-33779595680

Sincerely,
CascadiaRConf Organizers
(sent using `gmailr`)
"

# send emails
lapply(light_talks_notaccepted, function(z) {
  mime() %>%
    from("pdxrlang@gmail.com") %>%
    to(z$email) %>%
    #to("myrmecocystus@gmail.com") %>%
    subject("Your CascadiaRConf talk submission") %>%
    text_body(sprintf(email_text_not_accepted, z$`First Name`, z$`Talk Title`)) %>%
    #create_draft()
    send_message()
})

