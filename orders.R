library(dplyr)
library(readr)

#### People that signed up for two workshops
dat <- readr::read_csv("~/Desktop/report-2017-05-18T1138.csv")
to_email <- dat %>%
  filter(grepl("Workshop", `Ticket Type`)) %>%
  group_by(Email, `First Name`) %>%
  summarise(count = n()) %>%
  filter(count > 1)
to_email$`First Name` <- c(
  "Amirhosein", "Brice", "Gabriela", "Joe", "James", "Karess", "Lindsay",
  "Vera", "Kalbi"
)
to_email_list <- apply(to_email, 1, as.list)

library(gmailr)
email_text <- "Hi %s

Thanks for registering for CascadiaRConf. However, we noticed that you
signed up for both workshops. The workshops run concurrently, so you can
only attend one. Which would you like to attend? Reply to this email
with your choice.

Workshops are described here:
https://www.eventbrite.com/e/cascadia-r-conference-tickets-33779595680

Sincerely,
CascadiaRConf Organizers
(sent using `gmailr`)
"

lapply(to_email_list, function(z) {
  mime() %>%
    from("pdxrlang@gmail.com") %>%
    to(z$Email) %>%
    #to("myrmecocystus@gmail.com") %>%
    subject("Which workshop would you like to attend?") %>%
    text_body(sprintf(email_text, z$`First Name`)) %>%
    send_message()
})


#### People that didn't buy a ticket
dat <- readr::read_csv("~/Desktop/report-2017-05-18T1138.csv")
work <- dat %>%
  filter(grepl("Workshop", `Ticket Type`)) %>%
  select(Email) %>% distinct() %>% arrange()
tics <- dat %>%
  filter(!grepl("Workshop", `Ticket Type`)) %>%
  select(Email) %>% distinct() %>% arrange()

work_notics <- work$Email[!work$Email %in% tics$Email]

to_email2 <- dat %>%
  filter(Email %in% work_notics) %>%
  select(Email, `First Name`) %>%
  distinct()
to_email2_list <- apply(to_email2, 1, as.list)

library(gmailr)
email_buy_ticket_text <- "Hi %s

Thanks for registering for CascadiaRConf! However, we noticed that you
signed up for a workshop, but didn't buy a ticket. Tickets are $5 for
students and $30 otherwise. Please do buy a ticket.

We do have diversity grants to offset tickets/travel/etc. - let us
know if you are interested in applying.

Sincerely,
CascadiaRConf Organizers
(sent using `gmailr`)
"

lapply(to_email2_list, function(z) {
  mime() %>%
    from("pdxrlang@gmail.com") %>%
    to(z$Email) %>%
    #to("myrmecocystus@gmail.com") %>%
    subject("Question: No ticket for CascadiaRConf?") %>%
    text_body(sprintf(email_buy_ticket_text, z$`First Name`)) %>%
    send_message()
})
