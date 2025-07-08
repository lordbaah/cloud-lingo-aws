import { useState } from 'react';
import { HiChevronDown, HiSearch } from 'react-icons/hi';

interface Language {
  code: string;
  name: string;
}

interface LanguageSelectorProps {
  languages: Language[];
  selectedLanguage: string;
  onLanguageChange: (languageCode: string) => void;
  placeholder?: string;
}

export function LanguageSelector({
  languages,
  selectedLanguage,
  onLanguageChange,
  placeholder = 'Select language',
}: LanguageSelectorProps) {
  const [isOpen, setIsOpen] = useState(false);
  const [searchTerm, setSearchTerm] = useState('');

  const selectedLang = languages.find((lang) => lang.code === selectedLanguage);

  const filteredLanguages = languages.filter((lang) =>
    lang.name.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const handleSelect = (languageCode: string) => {
    onLanguageChange(languageCode);
    setIsOpen(false);
    setSearchTerm('');
  };

  return (
    <div className="relative">
      <button
        onClick={() => setIsOpen(!isOpen)}
        className="w-full px-4 py-3 text-left bg-white border border-gray-300 rounded-lg shadow-sm hover:border-gray-400 focus:outline-none focus:ring-2 focus:ring-tahiti focus:border-transparent transition-colors duration-200"
      >
        <div className="flex items-center justify-between">
          <span className={selectedLang ? 'text-gray-900' : 'text-gray-500'}>
            {selectedLang ? selectedLang.name : placeholder}
          </span>
          <HiChevronDown
            className={`w-5 h-5 text-gray-400 transition-transform duration-200 ${
              isOpen ? 'rotate-180' : ''
            }`}
          />
        </div>
      </button>

      {isOpen && (
        <div className="absolute z-10 w-full mt-1 bg-white border border-gray-300 rounded-lg shadow-lg max-h-60 overflow-hidden">
          {/* Search Input */}
          <div className="p-3 border-b border-gray-200">
            <div className="relative">
              <HiSearch className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-gray-400" />
              <input
                type="text"
                placeholder="Search languages..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-tahiti focus:border-transparent"
              />
            </div>
          </div>

          {/* Language List */}
          <div className="max-h-48 overflow-y-auto">
            {filteredLanguages.length > 0 ? (
              filteredLanguages.map((language) => (
                <button
                  key={language.code}
                  onClick={() => handleSelect(language.code)}
                  className={`w-full px-4 py-3 text-left hover:bg-gray-50 transition-colors duration-150 ${
                    selectedLanguage === language.code
                      ? 'bg-tahiti/10 text-midnight'
                      : 'text-gray-900'
                  }`}
                >
                  {language.name}
                </button>
              ))
            ) : (
              <div className="px-4 py-3 text-gray-500 text-center">
                No languages found
              </div>
            )}
          </div>
        </div>
      )}

      {/* Overlay to close dropdown */}
      {isOpen && (
        <div className="fixed inset-0 z-0" onClick={() => setIsOpen(false)} />
      )}
    </div>
  );
}
