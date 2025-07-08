interface TranslationResponse {
  original_text: string;
  translated_text: string;
  source_lang: string;
  target_lang: string;
}

export async function translateText(
  text: string,
  sourceLanguage: string,
  targetLanguage: string
): Promise<TranslationResponse> {
  // Replace this URL with your actual CloudLingo API endpoint
  const API_ENDPOINT =
    import.meta.env.VITE_TRANSLATE_API_URL ||
    'https://your-api-endpoint.com/translate';

  const requestBody = {
    text,
    source_lang: sourceLanguage,
    target_lang: targetLanguage,
  };

  try {
    const response = await fetch(API_ENDPOINT, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(requestBody),
    });

    if (!response.ok) {
      throw new Error(
        `Translation failed: ${response.status} ${response.statusText}`
      );
    }

    const data = await response.json();

    // Validate the response structure
    if (!data.translated_text) {
      throw new Error('Invalid response format from translation API');
    }

    console.log(data);
    return data;
  } catch (error) {
    console.error('Translation API error:', error);
    throw new Error(
      'Failed to translate text. Please check your connection and try again.'
    );
  }
}

// Example usage:
/*
  const result = await translateText("Hello, welcome to CloudLingo!", "en", "fr");
  console.log(result);
  // Output:
  // {
  //   "original_text": "Hello, welcome to CloudLingo!",
  //   "translated_text": "Bonjour, bienvenue à CloudLingo!",
  //   "source_lang": "en",
  //   "target_lang": "fr"
  // }
  */
