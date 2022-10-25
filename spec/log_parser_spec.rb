describe '#process' do
  context 'with valid input data' do
    let(:log_file) { 'spec/fixtures/webserver.log' }

    it 'should display the correct stats for the log file' do
      expect do
        process(log_file)
      end.to output(
        "\nTotal page views:\n\n/about/2 90 views\n/contact 89 views\n/index 82 views\n/about 81 views\n/help_page/1 80 views\n/home 78 views\n\n\nUnique page views:\n\n/index 23 unique views\n/home 23 unique views\n/contact 23 unique views\n/help_page/1 23 unique views\n/about/2 22 unique views\n/about 21 unique views\n\n"
      ).to_stdout
    end
  end

  context 'with invalid input data' do
    context 'with incorrect number of arguments' do
      xit 'should raise an error if no log file is provided' do
        expect { process }.to raise_error(ArgumentError)
      end
    
      xit 'should raise an error if more than one log file is provided' do
        expect { process('a', 'b') }.to raise_error(ArgumentError)
      end
    end

    context 'with incorrect file' do
      xit 'should raise an error if the log file does not exist' do
        expect { process('a') }.to raise_error(ArgumentError)
      end
    
      xit 'should raise an error if the log file is empty' do
        expect { process('spec/fixtures/empty.log') }.to raise_error(ArgumentError)
      end
    
      xit 'should raise an error if the log file is not in the correct format' do
        expect { process('spec/fixtures/invalid.log') }.to raise_error(ArgumentError)
      end
    end
  end
end

describe '#parse_logs' do
  context 'with correct input data' do
    let(:log_file) { 'spec/fixtures/webserver.log' }

    it 'should return the correct hash for the log file' do
      parsed_logs = parse_logs('spec/fixtures/webserver.log')

      expect(parsed_logs['/about/2']).to eq(
        { 
          total_count: 90,
          unique_count: 22,
          ips: [
            "444.701.448.104", "836.973.694.403", "184.123.665.067", "382.335.626.855", "543.910.244.929",
            "555.576.836.194", "802.683.925.780", "200.017.277.774", "126.318.035.038", "451.106.204.921",
            "235.313.352.950", "217.511.476.080", "316.433.849.805", "061.945.150.735", "715.156.286.412",
            "646.865.545.408", "016.464.657.359", "897.280.786.156", "682.704.613.213", "722.247.931.582",
            "158.577.775.616", "336.284.013.698"]
        }
      )
    end
  
    it 'should return the correct hash without duplicate ips' do
      parsed_logs = parse_logs('spec/fixtures/webserver.log')

      expect(parsed_logs['/contact'][:ips].uniq.length).to eq(parsed_logs['/contact'][:ips].length)
      expect(parsed_logs['/contact'][:ips].length).to eq(parsed_logs['/contact'][:unique_count])
    end
  end

  context 'with incorrect input data' do
    context 'with empty file' do 
      let(:log_file) { 'spec/fixtures/empty.log' }

      xit 'should return an empty hash if the log file is empty' do
        expect(parse_logs(log_file)).to eq({})
      end
    end

    context 'with wrong format' do
      let(:log_file) { 'spec/fixtures/empty.log' }

      xit 'should raise an error if the log file is not in the correct format' do
        expect(parse_logs(log_file)).to raise_error(ArgumentError)
      end
    end
  end
end

describe '#build_rank_lists' do
  context 'with valid input data' do
    it 'should return the correct rank lists' do
      parsed_logs = parse_logs('spec/fixtures/webserver.log')
      total, unique = build_rank_lists(parsed_logs)
  
      total.map { |page, stats| { page: page, count: stats[:total_count]} }.should eq(
        [
          { page: '/about/2', count: 90 },
          { page: '/contact', count: 89 },
          { page: '/index', count: 82 },
          { page: '/about', count: 81 },
          { page: '/help_page/1', count: 80 },
          { page: '/home', count: 78 }
        ]
      )
  
      unique.map { |page, stats| { page: page, count: stats[:unique_count]} }.should eq(
        [
          { page: '/index', count: 23 },
          { page: '/home', count: 23 },
          { page: '/contact', count: 23 },
          { page: '/help_page/1', count: 23 },
          { page: '/about/2', count: 22 },
          { page: '/about', count: 21 }
        ]
      )
    end
  end

  context 'with invalid input data' do
    xit 'should raise an error if the parsed logs are empty' do
      expect { build_rank_lists({}) }.to raise_error(ArgumentError)
    end
  end
end

describe '#display_stats' do
  context 'with valid input data' do
    let(:parsed_logs) { parse_logs('spec/fixtures/webserver.log') }

    it 'should display the correct stats' do
      total, unique = build_rank_lists(parsed_logs)

      expect do
        display_stats(total, unique)
      end.to output(
        "\nTotal page views:\n\n/about/2 90 views\n/contact 89 views\n/index 82 views\n/about 81 views\n/help_page/1 80 views\n/home 78 views\n\n\nUnique page views:\n\n/index 23 unique views\n/home 23 unique views\n/contact 23 unique views\n/help_page/1 23 unique views\n/about/2 22 unique views\n/about 21 unique views\n\n"
      ).to_stdout
    end
  end

  context 'with invalid input data' do
    xit 'should raise an error if the rank lists are empty' do
      expect { display_stats([], []) }.to raise_error(ArgumentError)
    end
  end
end