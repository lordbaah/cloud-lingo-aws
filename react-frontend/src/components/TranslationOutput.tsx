import { useState } from 'react';
import { HiClipboard, HiCheck } from 'react-icons/hi';

interface TranslationOutputProps {
  value: string;
  isLoading: boolean;
  language: string;
}

export function TranslationOutput({
  value,
  isLoading,
  language,
}: TranslationOutputProps) {
  const [copied, setCopied] = useState(false);

  const handleCopy = async () => {
    if (value) {
      try {
        await navigator.clipboard.writeText(value);
        setCopied(true);
        setTimeout(() => setCopied(false), 2000);
      } catch (err) {
        console.error('Failed to copy text:', err);
      }
    }
  };

  return (
    <div className="space-y-2">
      <div className="flex items-center justify-between">
        <h3 className="text-sm font-medium text-gray-700">
          {language || 'Target'}
        </h3>

        {value && !isLoading && (
          <button
            onClick={handleCopy}
            className="flex items-center gap-1 px-2 py-1 text-xs text-gray-600 hover:text-gray-800 transition-colors duration-200"
            title="Copy translation"
          >
            {copied ? (
              <>
                <HiCheck className="w-3 h-3" />
                Copied
              </>
            ) : (
              <>
                <HiClipboard className="w-3 h-3" />
                Copy
              </>
            )}
          </button>
        )}
      </div>

      <div className="relative">
        <div className="w-full h-40 p-4 bg-gray-50 border border-gray-300 rounded-lg overflow-y-auto">
          {isLoading ? (
            <div className="flex items-center justify-center h-full">
              <div className="flex items-center gap-2 text-gray-600">
                <div className="animate-spin rounded-full h-4 w-4 border-2 border-tahiti border-t-transparent"></div>
                Translating...
              </div>
            </div>
          ) : value ? (
            <p className="text-gray-900 whitespace-pre-wrap">{value}</p>
          ) : (
            <p className="text-gray-500 italic">
              Translation will appear here...
            </p>
          )}
        </div>
      </div>
    </div>
  );
}
