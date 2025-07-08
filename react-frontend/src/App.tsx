import { useState } from 'react';
import { LanguageSelector } from './components/LanguageSelector';
import { TranslationInput } from './components/TranslationInput';
import { TranslationOutput } from './components/TranslationOutput';
import { TranslationButton } from './components/TranslationButton';
import { SwapLanguagesButton } from './components/SwapLanguagesButton';
import { languages } from './libs/languages';
import { translateText } from './libs/api';

function App() {
  const [sourceLanguage, setSourceLanguage] = useState('en');
  const [targetLanguage, setTargetLanguage] = useState('fr');
  const [inputText, setInputText] = useState('');
  const [translatedText, setTranslatedText] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleTranslate = async () => {
    if (!inputText.trim()) {
      setError('Please enter text to translate');
      return;
    }

    if (sourceLanguage === targetLanguage) {
      setError('Please select different source and target languages');
      return;
    }

    setIsLoading(true);
    setError(null);

    try {
      const result = await translateText(
        inputText,
        sourceLanguage,
        targetLanguage
      );
      setTranslatedText(result.translated_text);
    } catch (err) {
      setError('Translation failed. Please try again.');
      console.error('Translation error:', err);
    } finally {
      setIsLoading(false);
    }
  };

  const handleSwapLanguages = () => {
    setSourceLanguage(targetLanguage);
    setTargetLanguage(sourceLanguage);
    setInputText(translatedText);
    setTranslatedText(inputText);
  };

  const handleClear = () => {
    setInputText('');
    setTranslatedText('');
    setError(null);
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-bermuda/20 to-tahiti/20 py-8 px-4">
      <div className="max-w-4xl mx-auto">
        {/* Header */}
        <div className="text-center mb-8">
          <h1 className="text-4xl font-bold text-midnight mb-2">
            CloudLingo Translator
          </h1>
          <p className="text-gray-600">
            Translate text between different languages using AWS Translate
          </p>
          <p>Testing CI/CD on Github</p>
        </div>

        {/* Main Translation Interface */}
        <div className="bg-white rounded-2xl shadow-xl p-6 md:p-8">
          {/* Language Selectors */}
          <div className="flex flex-col md:flex-row gap-4 mb-6">
            <div className="flex-1">
              <label className="block text-sm font-medium text-gray-700 mb-2">
                From
              </label>
              <LanguageSelector
                languages={languages}
                selectedLanguage={sourceLanguage}
                onLanguageChange={setSourceLanguage}
                placeholder="Select source language"
              />
            </div>

            <div className="flex items-end justify-center md:px-4">
              <SwapLanguagesButton onClick={handleSwapLanguages} />
            </div>

            <div className="flex-1">
              <label className="block text-sm font-medium text-gray-700 mb-2">
                To
              </label>
              <LanguageSelector
                languages={languages}
                selectedLanguage={targetLanguage}
                onLanguageChange={setTargetLanguage}
                placeholder="Select target language"
              />
            </div>
          </div>

          {/* Translation Areas */}
          <div className="grid md:grid-cols-2 gap-6 mb-6">
            <TranslationInput
              value={inputText}
              onChange={setInputText}
              placeholder="Enter text to translate..."
              language={
                languages.find((lang) => lang.code === sourceLanguage)?.name ||
                ''
              }
            />

            <TranslationOutput
              value={translatedText}
              isLoading={isLoading}
              language={
                languages.find((lang) => lang.code === targetLanguage)?.name ||
                ''
              }
            />
          </div>

          {/* Error Display */}
          {error && (
            <div className="mb-6 p-4 bg-red-50 border border-red-200 rounded-lg">
              <p className="text-red-700 text-sm">{error}</p>
            </div>
          )}

          {/* Action Buttons */}
          <div className="flex flex-col sm:flex-row gap-3 justify-center">
            <TranslationButton
              onClick={handleTranslate}
              isLoading={isLoading}
              disabled={!inputText.trim() || sourceLanguage === targetLanguage}
            />

            <button
              onClick={handleClear}
              className="px-6 py-3 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors duration-200 font-medium"
            >
              Clear
            </button>
          </div>
        </div>

        {/* Footer */}
        <div className="text-center mt-8 text-gray-500 text-sm">
          Powered by CloudLingo & AWS Translate
        </div>
      </div>
    </div>
  );
}

export default App;
