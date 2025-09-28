class ReceipeFromUrlService
  def initialize
  end

  def call
    schema = File.read("test.json")
    receipe = "https://www.bbc.co.uk/food/recipes/pretzels_71296"
    website_response = Faraday.get(receipe).body
    conn = Faraday.new(
      url: "http://localhost:11434",
      headers: { "Content-Type" => "application/json" },
      request: {
        open_timeout: 420,
        read_timeout: 420
      }
    )

    response = conn.post("/api/chat") do |req|
      req.body = {
        model: "gemma3",
        messages: [
          {
            role: "user",
            content: "I want you to go through this get request body response #{website_response} and convert the receipe information, description, instructions and ingredients into a JSON file. Use this json #{schema} as an example, as a schema. Don't copy the information in the schema, I want you to use it as a guide on how to format the json response. It needs to match the schema I have passed you. Also, don't summarise or change the content on the website, I want you only to convert the information into json. You can use teaspoon or tablespoon as mesurements but wherever possible use the metric system, not ounces or pounds or anything American. Please only include the JSON format in your response"
          }
        ],
        stream: false
      }.to_json
    end

    File.write(
      "test_2.json",
      JSON.parse(response.body).dig("message", "content")
    )
  end
end
