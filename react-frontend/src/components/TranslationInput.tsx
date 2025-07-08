import { HiX } from 'react-icons/hi';

interface TranslationInputProps {
  value: string;
  onChange: (value: string) => void;
  placeholder?: string;
  language: string;
}

export function TranslationInput({
  value,
  onChange,
  placeholder = 'Enter text to translate...',
  language,
}: TranslationInputProps) {
  const maxLength = 5000;

  return (
    <div className="space-y-2">
      <div className="flex items-center justify-between">
        <h3 className="text-sm font-medium text-gray-700">
          {language || 'Source'}
        </h3>
        <span className="text-xs text-gray-500">
          {value.length}/{maxLength}
        </span>
      </div>

      <div className="relative">
        <textarea
          value={value}
          onChange={(e) => onChange(e.target.value)}
          placeholder={placeholder}
          maxLength={maxLength}
          className="w-full h-40 p-4 border border-gray-300 rounded-lg resize-none focus:outline-none focus:ring-2 focus:ring-tahiti focus:border-transparent transition-colors duration-200 text-gray-900 placeholder-gray-500"
        />

        {value && (
          <button
            onClick={() => onChange('')}
            className="absolute top-3 right-3 p-1 text-gray-400 hover:text-gray-600 transition-colors duration-200"
            title="Clear text"
          >
            <HiX className="w-4 h-4" />
          </button>
        )}
      </div>
    </div>
  );
}
