require "govuk_tech_docs"

GovukTechDocs.configure(self)

ignore "templates/*"

proxy "/a-proxied-page.html", "templates/proxy_template.html", locals: {
  title: "I am a title",
}
